import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/pokemon.dart';
import '../providers/pokemon_provider.dart';
import '../screens/pokemon_detail_screen.dart';
import '../widgets/pokemon_card.dart';
import '../widgets/nickname_dialog.dart';

class PokedexScreen extends ConsumerStatefulWidget {
  const PokedexScreen({super.key});

  @override
  ConsumerState<PokedexScreen> createState() => _PokedexScreenState();
}

class _PokedexScreenState extends ConsumerState<PokedexScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) ref.read(pokemonProvider.notifier).fetchPokemon();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(pokemonProvider);
    final controller = ref.read(pokemonProvider.notifier);

    if (state.isLoading && state.pokemonList.isEmpty) {
      return const Scaffold(
        body: SafeArea(
          child: _StatusView(
            icon: null,
            message: 'Loading Pokémon...',
            loading: true,
          ),
        ),
      );
    }

    if (state.errorMessage != null && state.pokemonList.isEmpty) {
      return Scaffold(
        body: SafeArea(
          child: _StatusView(
            icon: Icons.wifi_off_outlined,
            message: state.errorMessage!,
            actionLabel: 'Try again',
            onAction: controller.fetchPokemon,
          ),
        ),
      );
    }

    if (state.pokemonList.isEmpty) {
      return const Scaffold(
        body: SafeArea(
          child: _StatusView(
            icon: Icons.catching_pokemon,
            message: 'No Pokémon found.',
          ),
        ),
      );
    }

    final types =
        state.pokemonList.expand((pokemon) => pokemon.types).toSet().toList()
          ..sort();

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 22, 18, 12),
              child: Row(
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
                  IconButton(
                    onPressed: () => _showFavorites(context),
                    tooltip: 'Show favorite Pokémon',
                    icon: Badge(
                      label: Text('${state.favoriteIds.length}'),
                      isLabelVisible: state.favoriteIds.isNotEmpty,
                      child: const Icon(
                        Icons.favorite,
                        color: Color(0xFFE94B50),
                      ),
                    ),
                  ),
                  Text(
                    state.rangeLabel,
                    style: const TextStyle(
                      color: Color(0xFF78817A),
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  IconButton(
                    onPressed: state.isLoading
                        ? null
                        : () => controller.refreshPokemon(),
                    tooltip: 'Refresh Pokémon',
                    icon: const Icon(Icons.refresh),
                    color: const Color(0xFF25312A),
                  ),
                ],
              ),
            ),
            if (state.errorMessage != null)
              Material(
                color: const Color(0xFFFFE7E3),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Color(0xFFB4383D),
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          state.errorMessage!,
                          style: const TextStyle(color: Color(0xFF8F292E)),
                        ),
                      ),
                      TextButton(
                        onPressed: state.isLoading
                            ? null
                            : () => controller.refreshPokemon(),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
              child: TextField(
                key: const ValueKey('pokemon-search'),
                controller: _searchController,
                onChanged: controller.setSearchQuery,
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: 'Search Pokémon by name, nickname, or number',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: state.searchQuery.isEmpty
                      ? null
                      : IconButton(
                          tooltip: 'Clear search',
                          onPressed: () {
                            _searchController.clear();
                            controller.setSearchQuery('');
                          },
                          icon: const Icon(Icons.clear),
                        ),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: Color(0xFFE6E9E3)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: Color(0xFFE6E9E3)),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            SizedBox(
              height: 48,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 18),
                children: [
                  _TypeChip(
                    label: 'All types',
                    selected: state.selectedType == null,
                    onSelected: () => controller.setTypeFilter(null),
                  ),
                  for (final type in types)
                    _TypeChip(
                      label: _capitalize(type),
                      selected: state.selectedType == type,
                      onSelected: () => controller.setTypeFilter(type),
                    ),
                ],
              ),
            ),
            if (state.isLoading) const LinearProgressIndicator(minHeight: 2),
            Expanded(
              child: RefreshIndicator(
                onRefresh: controller.refreshPokemon,
                child: state.filteredPokemon.isEmpty
                    ? ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: const [
                          SizedBox(height: 100),
                          Center(
                            child: Text(
                              'No Pokémon match your search or filter.',
                            ),
                          ),
                        ],
                      )
                    : LayoutBuilder(
                        builder: (context, constraints) {
                          final columns = switch (constraints.maxWidth) {
                            >= 900 => 4,
                            >= 600 => 3,
                            _ => 2,
                          };

                          return GridView.builder(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                            itemCount: state.filteredPokemon.length,
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: columns,
                                  crossAxisSpacing: 12,
                                  mainAxisSpacing: 12,
                                  childAspectRatio: 0.78,
                                ),
                            itemBuilder: (context, index) {
                              final pokemon = state.filteredPokemon[index];
                              return PokemonCard(
                                pokemon: pokemon,
                                displayName: state.displayName(pokemon),
                                isFavorite: state.favoriteIds.contains(
                                  pokemon.id,
                                ),
                                onFavoriteToggle: () =>
                                    controller.toggleFavorite(pokemon),
                                onEditNickname: () =>
                                    _editNickname(context, pokemon),
                                onTap: () {
                                  controller.selectPokemon(pokemon);
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          const PokemonDetailScreen(),
                                    ),
                                  );
                                },
                              );
                            },
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _editNickname(BuildContext context, Pokemon pokemon) async {
    final state = ref.read(pokemonProvider);
    final nickname = await showDialog<String>(
      context: context,
      builder: (context) => NicknameDialog(
        pokemonName: pokemon.name,
        initialNickname: state.nicknames[pokemon.id] ?? '',
      ),
    );
    if (nickname != null) {
      ref.read(pokemonProvider.notifier).setNickname(pokemon, nickname);
    }
  }

  void _showFavorites(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) => Consumer(
        builder: (context, ref, child) {
          final state = ref.watch(pokemonProvider);
          final controller = ref.read(pokemonProvider.notifier);
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Favorites (${state.favorites.length})',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  if (state.favorites.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Text(
                        'Tap the heart on a Pokémon card to add it here.',
                        textAlign: TextAlign.center,
                      ),
                    )
                  else
                    Flexible(
                      child: ListView(
                        shrinkWrap: true,
                        children: [
                          for (final pokemon in state.favorites)
                            ListTile(
                              leading: CircleAvatar(
                                backgroundColor: const Color(0xFFFFE7E3),
                                child: Text(
                                  '#${pokemon.id}',
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ),
                              title: Text(state.displayName(pokemon)),
                              subtitle: Text(
                                pokemon.types.map(_capitalize).join(' · '),
                              ),
                              trailing: IconButton(
                                tooltip: 'Remove from favorites',
                                icon: const Icon(
                                  Icons.favorite,
                                  color: Color(0xFFE94B50),
                                ),
                                onPressed: () =>
                                    controller.toggleFavorite(pokemon),
                              ),
                            ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  static String _capitalize(String value) =>
      value.isEmpty ? value : '${value[0].toUpperCase()}${value.substring(1)}';
}

class _TypeChip extends StatelessWidget {
  const _TypeChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onSelected(),
        showCheckmark: false,
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF59645C),
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
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
