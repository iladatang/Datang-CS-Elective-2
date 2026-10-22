import 'package:flutter/material.dart';

import '../models/pokemon.dart';

class PokemonCard extends StatelessWidget {
  const PokemonCard({
    super.key,
    required this.pokemon,
    required this.displayName,
    required this.isFavorite,
    required this.onFavoriteToggle,
    required this.onEditNickname,
    required this.onTap,
  });

  final Pokemon pokemon;
  final String displayName;
  final bool isFavorite;
  final VoidCallback onFavoriteToggle;
  final VoidCallback onEditNickname;
  final VoidCallback onTap;

  static const _backgrounds = [
    Color(0xFFFFE7E3),
    Color(0xFFE2F0E8),
    Color(0xFFFFF0D1),
    Color(0xFFE1EDF5),
  ];

  @override
  Widget build(BuildContext context) {
    final background = _backgrounds[(pokemon.id - 1) % _backgrounds.length];

    return Semantics(
      label: '$displayName, number ${pokemon.id}',
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE6E9E3)),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: background,
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.center,
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Hero(
                            tag: 'pokemon-${pokemon.id}',
                            child: Image.network(
                              pokemon.imageUrl,
                              fit: BoxFit.contain,
                              semanticLabel: displayName,
                              loadingBuilder: (context, child, progress) {
                                if (progress == null) return child;
                                return const Center(
                                  child: SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(
                                    Icons.catching_pokemon,
                                    size: 54,
                                    color: Color(0xFF98A19A),
                                  ),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 10,
                        left: 10,
                        child: IconButton.filledTonal(
                          constraints: const BoxConstraints.tightFor(
                            width: 34,
                            height: 34,
                          ),
                          padding: EdgeInsets.zero,
                          tooltip: isFavorite
                              ? 'Remove from favorites'
                              : 'Add to favorites',
                          onPressed: onFavoriteToggle,
                          icon: Icon(
                            isFavorite ? Icons.favorite : Icons.favorite_border,
                            size: 19,
                            color: isFavorite
                                ? const Color(0xFFE94B50)
                                : const Color(0xFF59645C),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 16,
                        right: 16,
                        child: Text(
                          '#${pokemon.id.toString().padLeft(3, '0')}',
                          style: const TextStyle(
                            color: Color(0xFF78817A),
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 0, 6, 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              displayName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Color(0xFF25312A),
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            if (pokemon.types.isNotEmpty)
                              Text(
                                pokemon.types.map(_capitalize).join(' · '),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Color(0xFF78817A),
                                  fontSize: 10,
                                ),
                              ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: onEditNickname,
                        tooltip: 'Edit nickname',
                        visualDensity: VisualDensity.compact,
                        icon: const Icon(Icons.edit_outlined, size: 18),
                        color: const Color(0xFF59645C),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static String _capitalize(String value) =>
      value.isEmpty ? value : '${value[0].toUpperCase()}${value.substring(1)}';
}
