import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/pokemon.dart';
import '../providers/pokemon_provider.dart';

class PokemonDetailScreen extends StatelessWidget {
  const PokemonDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<PokemonProvider>(
      builder: (context, provider, child) {
        final Pokemon? pokemon = provider.selectedPokemon;

        if (pokemon == null) {
          return const Scaffold(
            body: Center(child: Text('No Pokémon selected.')),
          );
        }

        final displayName =
            pokemon.name[0].toUpperCase() + pokemon.name.substring(1);

        return Scaffold(
          appBar: AppBar(
            title: const Text('Pokémon details'),
            centerTitle: true,
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
                        semanticLabel: displayName,
                        loadingBuilder: (context, child, progress) {
                          if (progress == null) return child;
                          return const SizedBox(
                            width: 48,
                            height: 48,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(
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
                      displayName,
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF25312A),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
