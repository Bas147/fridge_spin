# FridgeSpin

FridgeSpin is a mobile app that helps users randomize recipes based on ingredients in their fridge. Built with Flutter and Firebase, it offers a seamless experience for managing ingredients and discovering new recipes.

## Features

- Add, edit, and delete ingredients with details (name, quantity, expiry date, category)
- Randomize recipes based on available ingredients
- View detailed recipe information including ingredients and instructions
- Save favorite recipes for future reference
- Get notified when ingredients are about to expire

## Tech Stack

- **Frontend**: Flutter (Dart)
- **Backend**: Firebase Firestore
- **API**: Spoonacular API for recipe data
- **State Management**: Riverpod
- **Architecture**: Clean Architecture (Presentation, Domain, Data layers)

## Setup Instructions

### Prerequisites

- Flutter SDK (latest version recommended)
- Android Studio / VS Code with Flutter plugin
- Firebase account
- Spoonacular API key

### Firebase Setup

1. Create a new Firebase project at [Firebase Console](https://console.firebase.google.com/)
2. Add an Android app to your Firebase project
3. Follow the instructions to download the `google-services.json` file
4. Place the file in the `android/app` directory

### API Key Configuration

The app is already configured with a Spoonacular API key (`75fdfd1a86a74dda81f72b3e4f117fb9`). If you want to use your own API key:

1. Get an API key from [Spoonacular API](https://spoonacular.com/food-api)
2. Update the `apiKey` value in `lib/core/services/api_service.dart`

### Installation

1. Clone this repository
2. Run `flutter pub get` to install dependencies
3. Connect a device or start an emulator
4. Run `flutter run` to launch the app

## Project Structure

The project follows Clean Architecture principles:

```
lib/
  ├── core/                 # Core utilities, constants, and services
  │   ├── config/           # App configuration
  │   ├── constants/        # App constants
  │   ├── di/               # Dependency injection
  │   ├── services/         # Core services (Firebase, API)
  │   ├── theme/            # App theme and styling
  │   └── utils/            # Utility functions
  │
  └── features/             # App features
      ├── ingredient/       # Ingredient feature
      │   ├── data/         # Data layer (repositories impl, data sources)
      │   ├── domain/       # Domain layer (entities, repositories, use cases)
      │   └── presentation/ # Presentation layer (screens, widgets, providers)
      │
      ├── recipe/           # Recipe feature
      │   ├── data/
      │   ├── domain/
      │   └── presentation/
      │
      └── favorites/        # Favorites feature
          ├── data/
          ├── domain/
          └── presentation/
```

## Usage

1. **Add Ingredients**: Tap the "+" button to add ingredients
2. **Randomize Recipe**: Tap the "Randomize Recipe" button to get a recipe based on your ingredients
3. **View Recipe**: Tap "View Recipe" to see detailed instructions
4. **Try Another**: Tap "Try Another" to get a different recipe with the same ingredients
5. **Save to Favorites**: Tap the heart icon to save a recipe to favorites
6. **View Favorites**: Access your saved recipes from the side menu 