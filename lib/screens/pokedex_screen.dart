import 'package:flutter/material.dart';

import '../models/pokemon.dart';
import '../services/pokemon_service.dart';
import '../widgets/pokemon_card.dart';

class PokedexScreen extends StatefulWidget {
  const PokedexScreen({super.key, this.service});

  final PokemonService? service;

  @override
  State<PokedexScreen> createState() => _PokedexScreenState();
}

class _PokedexScreenState extends State<PokedexScreen> {
  late final PokemonService _service;
  late Future<List<Pokemon>> _pokemonFuture;

  @override
  void initState() {
    super.initState();
    _service = widget.service ?? PokemonService();
    _pokemonFuture = _service.fetchPokemon();
  }

  void _retry() {
    final future = _service.fetchPokemon();
    setState(() {
      _pokemonFuture = future;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
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
                  const Text(
                    '01 — 30',
                    style: TextStyle(
                      color: Color(0xFF78817A),
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: FutureBuilder<List<Pokemon>>(
                future: _pokemonFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const _StatusView(
                      icon: null,
                      message: 'Loading Pokémon...',
                      loading: true,
                    );
                  }

                  if (snapshot.hasError) {
                    return _StatusView(
                      icon: Icons.wifi_off_outlined,
                      message: "Couldn't load Pokémon.",
                      actionLabel: 'Try again',
                      onAction: _retry,
                    );
                  }

                  final pokemon = snapshot.data ?? const <Pokemon>[];
                  if (pokemon.isEmpty) {
                    return const _StatusView(
                      icon: Icons.catching_pokemon,
                      message: 'No Pokémon found.',
                    );
                  }

                  return LayoutBuilder(
                    builder: (context, constraints) {
                      final columns = switch (constraints.maxWidth) {
                        >= 900 => 4,
                        >= 600 => 3,
                        _ => 2,
                      };

                      return GridView.builder(
                        padding: const EdgeInsets.fromLTRB(20, 2, 20, 24),
                        itemCount: pokemon.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: columns,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.78,
                        ),
                        itemBuilder: (context, index) =>
                            PokemonCard(pokemon: pokemon[index]),
                      );
                    },
                  );
                },
              ),
            ),
          ],
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
