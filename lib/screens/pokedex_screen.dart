import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/pokemon.dart';
import '../providers/pokemon_provider.dart';
import '../screens/pokemon_detail_screen.dart';
import '../widgets/pokemon_card.dart';

class PokedexScreen extends StatefulWidget {
  const PokedexScreen({super.key});

  @override
  State<PokedexScreen> createState() => _PokedexScreenState();
}

class _PokedexScreenState extends State<PokedexScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<PokemonProvider>().fetchPokemon();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Consumer<PokemonProvider>(
          builder: (context, provider, child) {
            final pokemon = provider.pokemonList;

            if (provider.isLoading && pokemon.isEmpty) {
              return const _StatusView(
                icon: null,
                message: 'Loading Pokémon...',
                loading: true,
              );
            }

            if (provider.errorMessage != null && pokemon.isEmpty) {
              return _StatusView(
                icon: Icons.wifi_off_outlined,
                message: provider.errorMessage ?? "Couldn't load Pokémon.",
                actionLabel: 'Try again',
                onAction: () => provider.fetchPokemon(),
              );
            }

            if (pokemon.isEmpty) {
              return const _StatusView(
                icon: Icons.catching_pokemon,
                message: 'No Pokémon found.',
              );
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(22, 22, 22, 18),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: const BoxDecoration(
                          color: Color(0xFFE94B50),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.catching_pokemon,
                          color: Colors.white,
                          size: 29,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Pokédex',
                          style: TextStyle(
                            color: Color(0xFF25312A),
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      Text(
                        provider.rangeLabel,
                        style: const TextStyle(
                          color: Color(0xFF78817A),
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 4),
                      IconButton(
                        onPressed: provider.isLoading
                            ? null
                            : () => provider.refreshPokemon(),
                        tooltip: 'Refresh Pokémon',
                        icon: const Icon(Icons.refresh),
                        color: const Color(0xFF25312A),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async => provider.refreshPokemon(),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final columns = switch (constraints.maxWidth) {
                          >= 900 => 4,
                          >= 600 => 3,
                          _ => 2,
                        };

                        return GridView.builder(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(20, 2, 20, 24),
                          itemCount: pokemon.length,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: columns,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                                childAspectRatio: 0.78,
                              ),
                          itemBuilder: (context, index) {
                            final item = pokemon[index];
                            return GestureDetector(
                              onTap: () {
                                provider.selectPokemon(item);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const PokemonDetailScreen(),
                                  ),
                                );
                              },
                              child: PokemonCard(pokemon: item),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _StatusView extends StatelessWidget {
  const _StatusView({
    required this.icon,
    required this.message,
    this.loading = false,
    this.actionLabel,
    this.onAction,
  });

  final IconData? icon;
  final String message;
  final bool loading;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (loading)
            const CircularProgressIndicator()
          else if (icon != null)
            Icon(icon, size: 42, color: const Color(0xFF98A19A)),
          const SizedBox(height: 14),
          Text(
            message,
            style: const TextStyle(
              color: Color(0xFF59645C),
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (actionLabel != null) ...[
            const SizedBox(height: 12),
            FilledButton.tonalIcon(
              onPressed: onAction,
              icon: const Icon(Icons.refresh),
              label: Text(actionLabel!),
            ),
          ],
        ],
      ),
    );
  }
}
