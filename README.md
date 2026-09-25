# Catalog

A small Flutter app that uses [DummyJSON](https://dummyjson.com) to show products. You can browse in a grid or list, search for something, and tap a product to see its photos, rating, price and description.

## Running it

You'll need Flutter 3.44. The exact version is in `.fvmrc`.

```sh
flutter pub get
flutter run
```

To run the tests:

```sh
flutter test
```

## How it works

The app loads 20 products at a time and gets more as you scroll down. You can pull down to refresh or switch between the grid and list.

Search waits 350 ms after you stop typing before sending a request. It searches through the API so it can find products you haven't loaded yet. Pressing the keyboard's search button runs it straight away. Responses from an older search are ignored if you've changed the search text.

There’s a spinner while products load, a message when nothing is found, and a retry button if something goes wrong. If loading the next page fails, the products already on screen stay there. Images show a grey placeholder while loading and an icon if they fail.

## Code

It uses Material 3, Riverpod for state, `http` for API calls and `intl` for prices.

```text
lib/
├── main.dart
├── models/       Product data and JSON parsing
├── services/     API calls
├── providers/    State and app logic
├── screens/      Product list and detail screens
├── widgets/      Cards, list tiles, images and other shared widgets
├── theme/        Colors and font
└── utils/        Price formatting
```

Screens talk to providers, and providers use `ProductApi` to fetch data. The screens don't call the API themselves.

API failures become an `ApiException`, which the screens use to show messages like “No connection” or “Product not found”. There are tests for the models, API service, product list logic and main screen.

## Still to do

- Card-to-detail hero animation
- Dark theme
- Better support for large text—the grid cards have a fixed shape
- Image caching on disk
- Two-pane tablet layout