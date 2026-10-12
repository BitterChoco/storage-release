
---

## Shorter version

If you want a more compact README:

```md
# App Data

This repository contains the mobile app’s downloadable JSON data.

## Files
- `data/manifest.json`
- `data/categories.json`
- `data/pets.json`
- `data/pet_details.json`
- `data/settings.json`

## How it works
The app checks the manifest first, compares the remote version with the installed cache, and only downloads files that changed.

## Update process
- update JSON files
- bump version in `manifest.json`
- regenerate SHA-256 hash values
- commit and push

## Offline behavior
If the app is offline and local data exists, it loads the cached files. If no local data exists, it prompts the user to connect to the Internet.