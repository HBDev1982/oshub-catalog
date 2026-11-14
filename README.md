# OSHub device catalog

Hardware specs used by the OSHub macOS app (chip, RAM, display, storage, camera,
battery, connectivity, Apple Intelligence support, launch/latest OS), keyed by
Apple hardware identifier (e.g. `iPhone19,4`).

The app downloads `DeviceSpecs.json` at launch and merges it over its bundled
copy, so new models can be added here without shipping a new app build.

## Editing

- Keep the file a JSON **array** of objects with the same fields as the existing entries.
- `identifier`, `marketingName` and `supportsAppleIntelligence` are required; all other fields are optional.
- Leave a field out rather than guessing: the app shows "—" for missing values.
- An invalid or empty file is ignored by the app (it keeps its last good copy).
