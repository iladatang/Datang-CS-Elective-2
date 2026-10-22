import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/pokemon.dart';
import '../services/pokemon_service.dart';

final pokemonServiceProvider = Provider<PokemonService>(
  (ref) => PokemonService(),
);

final pokemonProvider = StateNotifierProvider<PokemonController, PokemonState>((
  ref,
) {
  return PokemonController(ref.watch(pokemonServiceProvider));
});

class PokemonState {
  const PokemonState({
    this.pokemonList = const [],
    this.isLoading = false,
    this.errorMessage,
    this.selectedPokemon,
    this.nicknames = const {},
    this.favoriteIds = const {},
    this.selectedType,
    this.searchQuery = '',
  });

  final List<Pokemon> pokemonList;
  final bool isLoading;
  final String? errorMessage;
  final Pokemon? selectedPokemon;
  final Map<int, String> nicknames;
  final Set<int> favoriteIds;
  final String? selectedType;
  final String searchQuery;

  List<Pokemon> get filteredPokemon {
    final query = searchQuery.trim().toLowerCase();
    return pokemonList
        .where((pokemon) {
          final matchesType =
              selectedType == null || pokemon.types.contains(selectedType);
          final matchesSearch =
              query.isEmpty ||
              pokemon.name.toLowerCase().contains(query) ||
              (nicknames[pokemon.id]?.toLowerCase().contains(query) ?? false) ||
              pokemon.id.toString() == query;
          return matchesType && matchesSearch;
        })
        .toList(growable: false);
  }

  List<Pokemon> get favorites =>
      pokemonList.where((pokemon) => favoriteIds.contains(pokemon.id)).toList();

  String displayName(Pokemon pokemon) =>
      nicknames[pokemon.id] ?? _capitalize(pokemon.name);

  String get rangeLabel {
    if (pokemonList.isEmpty) return '00 — 00';
    return '01 — ${pokemonList.length.toString().padLeft(2, '0')}';
  }

  static String _capitalize(String name) =>
      name.isEmpty ? name : '${name[0].toUpperCase()}${name.substring(1)}';

  PokemonState copyWith({
    List<Pokemon>? pokemonList,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
    Pokemon? selectedPokemon,
    Map<int, String>? nicknames,
    Set<int>? favoriteIds,
    String? selectedType,
    bool clearSelectedType = false,
    String? searchQuery,
  }) {
    return PokemonState(
      pokemonList: pokemonList ?? this.pokemonList,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      selectedPokemon: selectedPokemon ?? this.selectedPokemon,
      nicknames: nicknames ?? this.nicknames,
      favoriteIds: favoriteIds ?? this.favoriteIds,
      selectedType: clearSelectedType
          ? null
          : selectedType ?? this.selectedType,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class PokemonController extends StateNotifier<PokemonState> {
  PokemonController(this._service) : super(const PokemonState());

  final PokemonService _service;

  Future<void> fetchPokemon() async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final pokemon = await _service.fetchPokemon();
      state = state.copyWith(pokemonList: pokemon, isLoading: false);
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: error is PokemonApiException
            ? error.message
            : 'Something went wrong while fetching Pokémon.',
      );
    }
  }

  Future<void> refreshPokemon() => fetchPokemon();

  void selectPokemon(Pokemon pokemon) {
    state = state.copyWith(selectedPokemon: pokemon);
  }

  void setNickname(Pokemon pokemon, String nickname) {
    final nicknames = Map<int, String>.of(state.nicknames);
    final trimmed = nickname.trim();
    if (trimmed.isEmpty) {
      nicknames.remove(pokemon.id);
    } else {
      nicknames[pokemon.id] = trimmed;
    }
    state = state.copyWith(nicknames: nicknames);
  }

  void toggleFavorite(Pokemon pokemon) {
    final favorites = Set<int>.of(state.favoriteIds);
    if (!favorites.add(pokemon.id)) {
      favorites.remove(pokemon.id);
    }
    state = state.copyWith(favoriteIds: favorites);
  }

  void setTypeFilter(String? type) {
    state = state.copyWith(selectedType: type, clearSelectedType: type == null);
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }
}
