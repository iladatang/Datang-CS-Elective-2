import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:pokedex/models/pokemon.dart';
import 'package:pokedex/providers/pokemon_provider.dart';
import 'package:pokedex/screens/pokedex_screen.dart';
import 'package:pokedex/screens/pokemon_detail_screen.dart';
import 'package:pokedex/services/pokemon_service.dart';

void main() {
  test('provider loads and stores Pokémon from the API', () async {
    final service = FakePokemonService(
      () async => const [
        Pokemon(id: 1, name: 'bulbasaur'),
        Pokemon(id: 2, name: 'ivysaur'),
      ],
    );

    final provider = PokemonProvider(service: service);
    await provider.fetchPokemon();

    expect(provider.isLoading, isFalse);
    expect(provider.errorMessage, isNull);
    expect(provider.pokemonList.length, 2);
    expect(provider.pokemonList.first.name, 'bulbasaur');
  });

  testWidgets('shows a loading state while the request is pending', (
    tester,
  ) async {
    final result = Completer<List<Pokemon>>();
    final service = FakePokemonService(() => result.future);

    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => PokemonProvider(service: service),
        child: const MaterialApp(home: PokedexScreen()),
      ),
    );
    await tester.pump();

    expect(find.text('Loading Pokémon...'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('shows detail information from provider state', (tester) async {
    final provider = PokemonProvider(
      service: FakePokemonService(
        () async => const [Pokemon(id: 25, name: 'pikachu')],
      ),
    )..selectPokemon(const Pokemon(id: 25, name: 'pikachu'));

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: provider,
        child: const MaterialApp(home: PokemonDetailScreen()),
      ),
    );

    expect(find.text('Pikachu'), findsWidgets);
    expect(find.text('#025'), findsOneWidget);
    expect(find.byType(Image), findsOneWidget);
  });

  testWidgets('has a visible refresh action on the main screen', (tester) async {
    var calls = 0;
    final provider = PokemonProvider(
      service: FakePokemonService(() async {
        calls++;
        return calls == 1
            ? const [Pokemon(id: 1, name: 'bulbasaur')]
            : const [Pokemon(id: 2, name: 'ivysaur')];
      }),
    );

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: provider,
        child: const MaterialApp(home: PokedexScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.refresh), findsOneWidget);
    await tester.tap(find.byIcon(Icons.refresh));
    await tester.pumpAndSettle();

    expect(calls, 2);
    expect(find.text('Ivysaur'), findsOneWidget);
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
