# Wild Paw

Wild Paw's distributable assets and data files are stored in [`data/`](data/). The file [`data/manifest.json`](data/manifest.json) records each included file's path, size in bytes, and SHA-256 hash.

## Update the data manifest

Use [`update-manifest.ps1`](update-manifest.ps1) after adding, removing, or changing files under `data/`. The script recursively scans the data directory, excludes `manifest.json` itself, and writes a sorted file list with freshly calculated sizes and SHA-256 hashes. It preserves the manifest's existing `schemaVersion` and `version` values.

### Steps

1. Open PowerShell in the repository root or in the `wild-paw` directory.
2. Run the script:
   - From the repository root: `.\wild-paw\update-manifest.ps1`
   - From the `wild-paw` directory: `.\update-manifest.ps1`
3. Review the changes to `wild-paw/data/manifest.json` and commit the data changes and updated manifest together.

The script uses its own location to find `data/`, so it works from either directory. To preview the target without writing the manifest, add `-WhatIf` to either command. To scan a different data directory, pass `-DataDirectory <path>`; relative paths are resolved from the current PowerShell directory.

PowerShell's built-in file and JSON commands are used; no additional packages are required.
