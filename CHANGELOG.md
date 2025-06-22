# Changelog

## v0.5.1 - 2025-06-22

- Reworked how `superclass constraint` is mimicked

## v0.5.0 - 2025-02-20

- `Monad` opaque type.
- Refactored code into separate files for `types` and `instances`
- `Applicative` opaque type.

## v0.4.1 - 2025-02-19

- Used generic functions to mimic `instance constraints`.
- Made `NaturalTransformation` into an `opaque type`.
- Fixed `functor composition`.

## v0.4.0 - 2025-02-18

- `NaturalTransformation` type with examples and `composition`.
- Isomorphisms with `exponentials`.
- `Currying` and `uncurrying`.

## v0.3.0 - 2025-02-16

- `Profunctor` type with default functions and (->) instance.
- `Contravariant` type with default `operators`: replace and replace_flip.
- `Bifunctor` type with `default functions`, `instances` and `composition` type.
- `Reader` type.
- More `Functor` instances and default `operator`: replace.
- More basic concepts: `identity`, `constant`, `flip`.

## v0.2.0 - 2025-02-15

- Various functor `instances` and `examples`.
- `Functor` type, utilizing `Phantom` types to mimic type instances.

## v0.1.0 - 2025-02-15

- Algebra on types - various `isomorphisms`.
- `Writer` type.
- `Monoid` type and its instances.
- Basic category concepts such as: `composition`, `identity`, `unit`, `maybe`, `product`, `coproduct`.
