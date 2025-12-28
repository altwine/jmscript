# jmscript 0.0.1
**Right now this project is in beta, if you encounter any bug or undefined
behaviour: write an issue or do a pull request.**

This readme is a mess, some is actual useful information and some is just my
unfiltered thoughts. I will clean it up later.

# TODO
- Actually FIX checker!!!
- Move checker logic from codegen to checker;
- Proper if-else chains handling (there's no else handling right now);
- Implement `switch` statements with pattern matching stuff;
- Implement array/dictionary literals;
- Implement slices;
- Fix assets-related stuff!!! (use hashmap instead of costly switch lookups!);
- Merge integer and float because separation is useless;
- Rework the memory management.

# Building
**TL;DR**:
1. Make sure you have `odin` available globally.
2. Use `odin run ./scripts/update_assets` to update assets (mostly justmc & minecraft data).
3. Use `odin run ./scripts/build_prod` to compile the binary.

Before building, make sure you updated the assets, they're embedded into program at
compile-time. They're needed to make sure you using correct names/ids for blocks,
effects, enchantments, entities, items, particles, sounds.
Use `odin run ./scripts/update_assets` to update assets.

Use `odin run ./scripts/build_prod` to compile release-ready binary, or compile the debug
build using `odin run ./scripts/build_debug`.

# License
Check the [LICENSE](./LICENSE) file.
