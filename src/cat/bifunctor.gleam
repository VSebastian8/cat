//// `Bifunctor` type {minimal implementation - `bimap`}. \
//// Default functions: `first` and `second` (defined in terms of bimap).

import cat

/// `Bifunctor` type in gleam.
/// ```
/// // Haskell type class
/// class Bifunctor f where
///     bimap :: (a -> c) -> (b -> d) -> f a b -> f c d
///     first :: (a -> c) -> f a b -> f c b
///     first g = bimap g id
///     second :: (b -> d) -> f a b -> f a d
///     second = bimap id
/// ```
/// ### Examples
pub type Bifunctor(f, a, b, c, d, fab, fcd) {
  Bifunctor(bimap: fn(fn(a) -> c, fn(b) -> d) -> fn(fab) -> fcd)
}

/// Default function `first` for a given Bifunctor instance.
pub fn first(
  bifunctor: Bifunctor(f, a, b, c, b, fab, fcb),
) -> fn(fn(a) -> c) -> fn(fab) -> fcb {
  fn(g) { bifunctor.bimap(g, cat.id) }
}

/// Default function `second` for a given Bifunctor instance.
pub fn second(
  bifunctor: Bifunctor(f, a, b, a, d, fab, fad),
) -> fn(fn(b) -> d) -> fn(fab) -> fad {
  fn(h) { bifunctor.bimap(cat.id, h) }
}
