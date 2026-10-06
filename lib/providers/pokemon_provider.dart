import 'package:flutter/foundation.dart';

import '../models/pokemon.dart';
import '../services/pokemon_service.dart';

class PokemonProvider extends ChangeNotifier {
  PokemonProvider({PokemonService? service})
    : _service = service ?? PokemonService();

  final PokemonService _service;

  List<Pokemon> _pokemonList = const [];
  bool _isLoading = false;
  String? _errorMessage;
  Pokemon? _selectedPokemon;

  List<Pokemon> get pokemonList => _pokemonList;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Pokemon? get selectedPokemon => _selectedPokemon;

  String get rangeLabel {
    if (_pokemonList.isEmpty) {
      return '00 — 00';
    }
    return '01 — ${_pokemonList.length.toString().padLeft(2, '0')}';
  }

  Future<void> fetchPokemon() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _pokemonList = await _service.fetchPokemon();
    } catch (error) {
      _errorMessage = error is PokemonApiException
          ? error.message
          : 'Something went wrong while fetching Pokémon.';
      _pokemonList = const [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshPokemon() => fetchPokemon();

  void selectPokemon(Pokemon pokemon) {
    _selectedPokemon = pokemon;
    notifyListeners();
  }
}
