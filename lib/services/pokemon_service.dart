import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/pokemon.dart';

class PokemonService {
  PokemonService([this._client]);

  final http.Client? _client;

  Future<List<Pokemon>> fetchPokemon() async {
    final uri = Uri.https('pokeapi.co', '/api/v2/pokemon', {'limit': '30'});
    final response = await (_client?.get(uri) ?? http.get(uri)).timeout(
      const Duration(seconds: 15),
    );

    if (response.statusCode != 200) {
      throw PokemonApiException(
        'Request failed with status ${response.statusCode}.',
      );
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic> || decoded['results'] is! List) {
      throw const PokemonApiException('The API returned an invalid response.');
    }

    return (decoded['results'] as List)
        .map((entry) {
          if (entry is! Map<String, dynamic>) {
            throw const FormatException('Invalid Pokémon entry.');
          }
          return Pokemon.fromJson(entry);
        })
        .toList(growable: false);
  }
}

class PokemonApiException implements Exception {
  const PokemonApiException(this.message);

  final String message;

  @override
  String toString() => message;
}
