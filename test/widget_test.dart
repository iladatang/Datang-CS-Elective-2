import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex/models/pokemon.dart';
import 'package:pokedex/providers/pokemon_provider.dart';
import 'package:pokedex/screens/pokedex_screen.dart';
import 'package:pokedex/screens/pokemon_detail_screen.dart';
import 'package:pokedex/services/pokemon_service.dart';

void main() {
  test('controller loads and stores Pokémon from the API', () async {
    final service = FakePokemonService(
      () async => const [
        Pokemon(id: 1, name: 'bulbasaur', types: ['grass', 'poison']),
        Pokemon(id: 2, name: 'ivysaur', types: ['grass', 'poison']),
      ],
    );

    final controller = PokemonController(service);
    await controller.fetchPokemon();

    expect(controller.state.isLoading, isFalse);
    expect(controller.state.errorMessage, isNull);
    expect(controller.state.pokemonList.length, 2);
    expect(controller.state.pokemonList.first.name, 'bulbasaur');
    expect(controller.state.pokemonList.first.types, ['grass', 'poison']);
  });

  test('nickname, favorite, and type filter update the shared state', () async {
    final bulbasaur = const Pokemon(
      id: 1,
      name: 'bulbasaur',
      types: ['grass', 'poison'],
    );
    final charmander = const Pokemon(
      id: 4,
      name: 'charmander',
      types: ['fire'],
    );
    final controller = PokemonController(
      FakePokemonService(() async => [bulbasaur, charmander]),
    );
    await controller.fetchPokemon();

    controller.setNickname(bulbasaur, 'Sprout');
    controller.toggleFavorite(bulbasaur);
    controller.setTypeFilter('grass');
    controller.setSearchQuery('spr');

    expect(controller.state.displayName(bulbasaur), 'Sprout');
    expect(controller.state.favorites, [bulbasaur]);
    expect(controller.state.filteredPokemon, [bulbasaur]);

    controller.setTypeFilter(null);
    controller.setSearchQuery('4');
    expect(controller.state.filteredPokemon, [charmander]);

    controller.setSearchQuery('');
    controller.setTypeFilter('grass');
    controller.setNickname(bulbasaur, ' ');
    expect(controller.state.displayName(bulbasaur), 'Bulbasaur');
  });

  testWidgets('shows a loading state while the request is pending', (
    tester,
  ) async {
    final result = Completer<List<Pokemon>>();
    final service = FakePokemonService(() => result.future);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [pokemonServiceProvider.overrideWithValue(service)],
        child: const MaterialApp(home: PokedexScreen()),
      ),
    );
    await tester.pump();

    expect(find.text('Loading Pokémon...'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    result.complete(const [Pokemon(id: 1, name: 'bulbasaur')]);
    await tester.pumpAndSettle();
  });

  testWidgets('shows detail information from Riverpod state', (tester) async {
    const pikachu = Pokemon(id: 25, name: 'pikachu', types: ['electric']);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          pokemonProvider.overrideWith(
            (ref) => PokemonController(
              FakePokemonService(() async => const [pikachu]),
            )..selectPokemon(pikachu),
          ),
        ],
        child: const MaterialApp(home: PokemonDetailScreen()),
      ),
    );

    expect(find.text('Pikachu'), findsOneWidget);
    expect(find.text('#025'), findsOneWidget);
    expect(find.text('Electric'), findsOneWidget);
    expect(find.byType(Image), findsOneWidget);
  });

  testWidgets('home page provides favorites and type filters', (tester) async {
    final service = FakePokemonService(
      () async => const [
        Pokemon(id: 1, name: 'bulbasaur', types: ['grass', 'poison']),
        Pokemon(id: 4, name: 'charmander', types: ['fire']),
      ],
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [pokemonServiceProvider.overrideWithValue(service)],
        child: const MaterialApp(home: PokedexScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('All types'), findsOneWidget);
    expect(find.widgetWithText(ChoiceChip, 'Fire'), findsOneWidget);
    expect(find.widgetWithText(ChoiceChip, 'Grass'), findsOneWidget);
    expect(find.byTooltip('Show favorite Pokémon'), findsOneWidget);

    await tester.enterText(
      find.byKey(const ValueKey('pokemon-search')),
      'charm',
    );
    await tester.pumpAndSettle();
    expect(find.text('Charmander'), findsOneWidget);
    expect(find.text('Bulbasaur'), findsNothing);
    await tester.tap(find.byTooltip('Clear search'));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Edit nickname').first);
    await tester.pumpAndSettle();
    await tester.enterText(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.byType(TextField),
      ),
      'Sprout',
    );
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(find.text('Sprout'), findsOneWidget);

    await tester.tap(find.byTooltip('Add to favorites').first);
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(ChoiceChip, 'Fire'));
    await tester.pumpAndSettle();
    expect(find.text('Charmander'), findsOneWidget);
    expect(find.text('Bulbasaur'), findsNothing);

    await tester.tap(find.byTooltip('Show favorite Pokémon'));
    await tester.pumpAndSettle();
    expect(find.text('Favorites (1)'), findsOneWidget);
    expect(find.text('Sprout'), findsOneWidget);
  });

  test('uses the URL ID and builds the artwork URL', () {
    final pokemon = Pokemon.fromJson({
      'name': 'pikachu',
      'url': 'https://pokeapi.co/api/v2/pokemon/25/',
    });

    expect(pokemon.id, 25);
    expect(pokemon.imageUrl, contains('/official-artwork/25.png'));
  });
}

class FakePokemonService extends PokemonService {
  FakePokemonService(this.fetch);

  final Future<List<Pokemon>> Function() fetch;

  @override
  Future<List<Pokemon>> fetchPokemon() => fetch();
}
