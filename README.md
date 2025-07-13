# UT Ad Leika - Iceland Playground Locator

A Flutter mobile application that helps users discover and navigate to playgrounds in Hafnarfjörður, Iceland. The app features location-based search, distance sorting, detailed playground information, and integrated maps - all powered by offline geographic data.

## 🌟 Features

- **📍 Location-Based Discovery**: Find playgrounds near your current location
- **📏 Distance Sorting**: Playgrounds automatically sorted by proximity
- **🗺️ Interactive Maps**: Detailed Google Maps integration with user location
- **🎮 Playground Details**: Comprehensive information about facilities and amenities
- **🚀 Offline-First**: Works with pre-loaded geographic data
- **🌍 Icelandic Localization**: Native support for Icelandic language
- **📱 Modern UI**: Clean, intuitive design following Material Design principles

## 🏗️ Architecture

The app follows **Clean Architecture** principles with a clear separation of concerns:

- **Presentation Layer**: Flutter widgets with Atomic Design (atoms → organisms)
- **Application Layer**: Business logic handled by Cubits (BLoC pattern)
- **Domain Layer**: Pure business entities and use cases  
- **Infrastructure Layer**: External data sources, repositories, and services

### Key Technologies

- **State Management**: Flutter BLoC (Cubit pattern)
- **Dependency Injection**: Injectable + GetIt
- **Reactive Streams**: RxDart BehaviorSubject
- **Local Storage**: Hive for caching
- **Maps**: Google Maps Flutter
- **Location Services**: Geolocator

## 📋 Prerequisites

Before running the app, ensure you have:

- **Flutter SDK** `>=3.32.5`
- **Dart SDK** `>=3.8.1`
- **Android Studio** or **VS Code** with Flutter extension
- **Google Maps API Key** (for map functionality)
- **Python 3.8+** (for data processing)

## 🚀 Getting Started

### 1. Clone and Setup

```bash
git clone <repository-url>
cd ut_ad_leika
flutter pub get
```

### 2. Configure Google Maps API

Create a Google Cloud project and enable the Maps SDK:

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project or select existing
3. Enable **Maps SDK for Android**
4. Create an API key with Maps access
5. Add your API key to `android/app/src/main/AndroidManifest.xml`:

```xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="YOUR_API_KEY_HERE" />
```

### 3. Generate Code

Run code generation for dependency injection and assets:

```bash
dart run build_runner build --delete-conflicting-outputs
```

### 4. Run the App

```bash
flutter run
```

## 📊 Offline Data & Python Script

### The Offline Approach

This app uses **offline geographic data** to provide fast, reliable playground information without requiring constant internet connectivity. The playground data is stored as a GeoJSON file in the app bundle.

**Location**: `assets/offline/geo/hafnarfjordur_playgrounds_geocoded.geojson`

### Data Processing Script

The project includes a Python script for processing and enriching playground data:

**Location**: `support/playground_geocoder.py`

#### What the Script Does

1. **Geocoding**: Converts playground coordinates to human-readable addresses
2. **Google Maps Integration**: Uses Google Geocoding API for accurate address data
3. **Caching**: Implements intelligent caching to avoid duplicate API calls
4. **Resumable Processing**: Supports checkpoint-based processing for large datasets
5. **Error Handling**: Robust retry logic and error recovery

#### Using the Script

```bash
# Install Python dependencies
pip install requests tqdm

# Process playground data
python support/playground_geocoder.py \
  input.geojson \
  output.geojson \
  --apikey YOUR_GOOGLE_API_KEY \
  --language is \
  --delay 0.1
```

#### Script Options

- `--apikey`: Your Google Geocoding API key (required)
- `--delay`: Seconds between API requests (default: 0.1)
- `--language`: Address language/locale (default: "is" for Icelandic)
- `--retries`: Number of retry attempts (default: 3)
- `--no-cache`: Disable coordinate caching
- `--resume`: Resume from checkpoint file
- `--checkpoint-interval`: Save checkpoint every N features (default: 10)

#### Example Usage

```bash
# Process OSM playground data with Icelandic addresses
python support/playground_geocoder.py \
  raw_playgrounds.geojson \
  assets/offline/geo/hafnarfjordur_playgrounds_geocoded.geojson \
  --apikey AIza... \
  --language is \
  --delay 0.1 \
  --checkpoint-interval 5
```

### Data Structure

The GeoJSON file contains playground features with enriched data:

```json
{
  "type": "FeatureCollection",
  "features": [
    {
      "type": "Feature",
      "geometry": {
        "type": "Point",
        "coordinates": [longitude, latitude]
      },
      "properties": {
        "@id": "unique_id",
        "amenity": "playground",
        "address": {
          "google_formatted": "Street Name 123, 220 Hafnarfjörður, Iceland",
          "google_components": [...]
        }
      }
    }
  ]
}
```

## 🗂️ Project Structure

```
lib/
├── application/           # Business logic (Cubits)
│   ├── core/             # Base classes and utilities
│   ├── location_detail/  # Location detail screen logic
│   └── location_list/    # Location list screen logic
├── domain/               # Business entities and rules
│   ├── core/            # Shared value objects
│   └── locations/       # Location-specific domain logic
├── infrastructure/       # External dependencies
│   ├── core/            # Shared infrastructure
│   └── locations/       # Location data sources
├── presentation/         # UI layer
│   ├── core/            # Shared UI components
│   ├── location_detail/ # Location detail screens
│   └── location_list/   # Location list screens
└── setup.dart           # Dependency injection setup

assets/
├── offline/geo/         # Geographic data files
├── animations/          # Lottie animations
├── icons/              # SVG icons and flags
├── images/             # Static images
└── illustrations/      # Light/dark illustrations

support/
└── playground_geocoder.py  # Data processing script
```

## 🎯 Key Features in Detail

### Location Permission Flow

1. **List View**: Permission requested upfront with clear UI feedback
2. **Banner System**: Shows permission status with retry options
3. **Distance Sorting**: Closest playgrounds appear first when location is available

### Map Integration

- **Dual Context**: Maps in both list and detail views
- **Standard Location Display**: Uses Google Maps SDK's built-in location indicators
- **Smart Camera Fitting**: Automatically frames user location and selected playground
- **Fallback Support**: Graceful degradation when location unavailable

### Offline-First Design

- **Bundled Data**: All playground information included in app bundle
- **Fast Loading**: No network dependency for core functionality
- **Consistent Performance**: Same experience regardless of connectivity

## 🛠️ Development

### Code Generation

The project uses several code generators:

```bash
# Generate dependency injection
dart run build_runner build --delete-conflicting-outputs

# Generate internationalization
dart run intl_utils:generate

# Generate launcher icons
dart run flutter_launcher_icons
```

### Running Tests

```bash
flutter test
```

### Building for Release

```bash
# Android
flutter build apk --release
flutter build appbundle --release
```

## 📝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Follow the existing architecture patterns
4. Ensure all code is properly tested
5. Commit changes (`git commit -m 'Add amazing feature'`)
6. Push to branch (`git push origin feature/amazing-feature`)
7. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- **OpenStreetMap**: Source of playground geographic data
- **Google Maps**: Geocoding and mapping services
- **Hafnarfjörður Municipality**: Target area for playground data
- **Flutter Community**: Amazing framework and ecosystem
