import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/pokemon.dart';

class PokemonService {
  PokemonService([this._client]);

  final http.Client? _client;

  Future<List<Pokemon>> fetchPokemon() async {
    final uri = Uri.https('pokeapi.co', '/api/v2/pokemon', {'limit': '30'});
    final decoded = await _getJson(uri);
    if (decoded is! Map<String, dynamic> || decoded['results'] is! List) {
      throw const PokemonApiException('The API returned an invalid response.');
    }

    final entries = (decoded['results'] as List)
        .map((entry) {
          if (entry is! Map<String, dynamic>) {
            throw const FormatException('Invalid Pokémon entry.');
          }
          return Pokemon.fromJson(entry);
        })
        .toList(growable: false);

    final pokemon = <Pokemon>[];
    for (var start = 0; start < entries.length; start += 5) {
      final end = (start + 5 < entries.length) ? start + 5 : entries.length;
      pokemon.addAll(
        await Future.wait(
          entries
              .sublist(start, end)
              .map((entry) => _fetchPokemonDetails(entry)),
        ),
      );
    }
    return pokemon;
  }

  Future<Pokemon> _fetchPokemonDetails(Pokemon pokemon) async {
    final decoded = await _getJson(
      Uri.https('pokeapi.co', '/api/v2/pokemon/${pokemon.id}'),
    );
    if (decoded is! Map<String, dynamic> || decoded['types'] is! List) {
      throw const PokemonApiException(
        'The API returned invalid Pokémon types.',
      );
    }

    final types = (decoded['types'] as List)
        .map((entry) {
          if (entry is! Map<String, dynamic> ||
              entry['type'] is! Map<String, dynamic> ||
              (entry['type'] as Map<String, dynamic>)['name'] is! String) {
            throw const PokemonApiException(
              'The API returned invalid Pokémon types.',
            );
          }
          return (entry['type'] as Map<String, dynamic>)['name'] as String;
        })
        .toList(growable: false);

    return Pokemon(id: pokemon.id, name: pokemon.name, types: types);
  }

  Future<dynamic> _getJson(Uri uri) async {
    final response = await (_client?.get(uri) ?? http.get(uri)).timeout(
      const Duration(seconds: 15),
    );
    if (response.statusCode != 200) {
      throw PokemonApiException(
        'Request failed with status ${response.statusCode}.',
      );
    }
    try {
      return jsonDecode(response.body);
    } on FormatException {
      throw const PokemonApiException('The API returned invalid JSON.');
    }
  }
}

class PokemonApiException implements Exception {
  const PokemonApiException(this.message);

  final String message;

  @override
  String toString() => message;
}
