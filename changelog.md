# Changelog

## Version 1.0.0

initial version

## Version 2.0.0

- Breaking changes (Not compatible to the initial version 1.0.0)

- The hashList is now using indizes (from module Vector), so that
  getting values per index is really fast.

- Class usage and static (stable) usage is possible

## Version 3.0.0

- Referenced packages upgraded

- Removed memory-buffer reference (because of conflicting version of transitive
  package memory-region). We only use the Blobify-code and this is now copy and pasted, so that the memory-buffer not needed anymore directly.
