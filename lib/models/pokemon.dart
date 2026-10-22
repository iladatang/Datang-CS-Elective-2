class Pokemon {
  const Pokemon({required this.id, required this.name, this.types = const []});

  final int id;
  final String name;
  final List<String> types;

  String get imageUrl =>
      'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/$id.png';

  factory Pokemon.fromJson(Map<String, dynamic> json) {
    final name = json['name'];
    final url = json['url'];
    if (name is! String || url is! String) {
      throw const FormatException('Invalid Pokémon entry.');
    }

    final match = RegExp(r'/pokemon/(\d+)/?$').firstMatch(url);
    final id = int.tryParse(match?.group(1) ?? '');
    if (id == null) {
      throw const FormatException('Invalid Pokémon resource URL.');
    }

    return Pokemon(id: id, name: name);
  }
}
