// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex/models/pokemon.dart';
import 'package:pokedex/screens/pokedex_screen.dart';
import 'package:pokedex/services/pokemon_service.dart';

void main() {
  testWidgets('shows fetched Pokémon in the grid', (tester) async {
    final service = FakePokemonService(
      () async => const [
        Pokemon(id: 1, name: 'bulbasaur'),
        Pokemon(id: 2, name: 'ivysaur'),
      ],
    );

    await tester.pumpWidget(MaterialApp(home: PokedexScreen(service: service)));
    await tester.pumpAndSettle();

    expect(find.text('Bulbasaur'), findsOneWidget);
    expect(find.text('Ivysaur'), findsOneWidget);
    expect(find.text('#001'), findsOneWidget);
    expect(find.byType(GridView), findsOneWidget);
  });

  testWidgets('shows a loading state while the request is pending', (
    tester,
  ) async {
    final result = Completer<List<Pokemon>>();
    final service = FakePokemonService(() => result.future);

    await tester.pumpWidget(MaterialApp(home: PokedexScreen(service: service)));

    expect(find.text('Loading Pokémon...'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('shows the empty state for an empty response', (tester) async {
    final service = FakePokemonService(() async => const []);

    await tester.pumpWidget(MaterialApp(home: PokedexScreen(service: service)));
    await tester.pumpAndSettle();

    expect(find.text('No Pokémon found.'), findsOneWidget);
  });

  testWidgets('shows an error state and retries the request', (tester) async {
    var attempts = 0;
    final service = FakePokemonService(() async {
      attempts++;
      if (attempts == 1) throw Exception('offline');
      return const [Pokemon(id: 25, name: 'pikachu')];
    });

    await tester.pumpWidget(MaterialApp(home: PokedexScreen(service: service)));
    await tester.pumpAndSettle();

    expect(find.text("Couldn't load Pokémon."), findsOneWidget);
    await tester.tap(find.text('Try again'));
    await tester.pumpAndSettle();

    expect(find.text('Pikachu'), findsOneWidget);
    expect(attempts, 2);
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

class FakePokemonService implements PokemonService {
  FakePokemonService(this.fetch);

  final Future<List<Pokemon>> Function() fetch;

  @override
  Future<List<Pokemon>> fetchPokemon() => fetch();
}
