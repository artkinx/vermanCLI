# Verman Example Project

This directory contains a sample Flutter project structure to demonstrate the capabilities of the `verman` CLI tool.

For full documentation on `verman`, please see the main README.md in the root of this repository.

## How to Use

1. Navigate into this directory:
   ```sh
   cd example
   ```

2. Run `verman` commands using `dart run`:
   ```sh
   # Check the current version
   dart run verman current

   # Increment the patch version
   dart run verman increment patch
   ```

To reset changes after testing, you can use `git checkout -- .` inside this directory.