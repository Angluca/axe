This directory contains the self-hosted version of the Axe compiler, written in Axe itself.

## Status: WIP

### TODO

#### Bugfixes

- [x] Fix `[]` syntax with non-primitive types

#### Overarching

- [x] **lexer.axe** - Lexical Analysis and Tokenization
- [x] **parser.axe** - Parse tokens into an AST
- [x] **builds.axe** - Build orchestration
- [x] **structs.axe** - Structs and enums
- [ ] **renderer.axe** - Renderer for AST
- [ ] **imports.axe** - Module import resolution
- [ ] Derive module names from file path (and directory) in `builds.axe` to match D compiler semantics
- [ ] Implement richer import semantics and name rewriting (prefixed calls, selective imports, visibility) in `imports.axe`
