# Pokédex

Midterm exam project for CS Elective 2: Mobile Development with Flutter.

## Features

- Browse the first 30 Pokémon with artwork and PokéAPI types.
- Search Pokémon by name, nickname, or Pokédex number.
- Filter the list by Pokémon type.
- Set or clear a nickname from a Pokémon card or its details page.
- Add Pokémon to favorites, see the favorites panel, and remove favorites.
- Refresh the list with pull-to-refresh or the refresh action.

Riverpod is the app's state-management solution. Pokémon information is loaded
from [PokéAPI](https://pokeapi.co/); an internet connection is required to load
the list and artwork.

## Run

```sh
flutter pub get
flutter run
```

## Test

```sh
flutter test
```
