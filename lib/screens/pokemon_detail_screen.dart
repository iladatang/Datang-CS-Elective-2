import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/pokemon.dart';
import '../providers/pokemon_provider.dart';
import '../widgets/nickname_dialog.dart';

class PokemonDetailScreen extends ConsumerWidget {
  const PokemonDetailScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(pokemonProvider);
    final Pokemon? pokemon = state.selectedPokemon;

    if (pokemon == null) {
      return const Scaffold(body: Center(child: Text('No Pokémon selected.')));
    }

    final isFavorite = state.favoriteIds.contains(pokemon.id);
    final nickname = state.nicknames[pokemon.id];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pokémon details'),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: isFavorite ? 'Remove from favorites' : 'Add to favorites',
            onPressed: () =>
                ref.read(pokemonProvider.notifier).toggleFavorite(pokemon),
            icon: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: isFavorite ? const Color(0xFFE94B50) : null,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Hero(
                  tag: 'pokemon-${pokemon.id}',
                  child: Image.network(
                    pokemon.imageUrl,
                    height: 220,
                    fit: BoxFit.contain,
                    semanticLabel: state.displayName(pokemon),
                    loadingBuilder: (context, child, progress) {
                      if (progress == null) return child;
                      return const SizedBox(
                        width: 48,
                        height: 48,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.catching_pokemon,
                      size: 80,
                      color: Color(0xFF98A19A),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  '#${pokemon.id.toString().padLeft(3, '0')}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF78817A),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  state.displayName(pokemon),
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF25312A),
                  ),
                ),
                if (nickname != null && nickname.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Nickname for ${_capitalize(pokemon.name)}',
                    style: const TextStyle(color: Color(0xFF78817A)),
                  ),
                ],
                if (pokemon.types.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    children: [
                      for (final type in pokemon.types)
                        Chip(label: Text(_capitalize(type))),
                    ],
                  ),
                ],
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: () => _editNickname(context, ref, pokemon),
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text('Edit nickname'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _editNickname(
    BuildContext context,
    WidgetRef ref,
    Pokemon pokemon,
  ) async {
    final nickname = await showDialog<String>(
      context: context,
      builder: (context) => NicknameDialog(
        pokemonName: pokemon.name,
        initialNickname: ref.read(pokemonProvider).nicknames[pokemon.id] ?? '',
      ),
    );
    if (nickname != null) {
      ref.read(pokemonProvider.notifier).setNickname(pokemon, nickname);
    }
  }

  static String _capitalize(String value) =>
      value.isEmpty ? value : '${value[0].toUpperCase()}${value.substring(1)}';
}
