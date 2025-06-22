//// `Bifunctor` type {minimal implementation - `bimap`}. \
//// Default functions: `first` and `second` (defined in terms of bimap). \
//// Bifunctor `composition`.

import cat
import cat/functor.{type Functor}
import cat/instances/types.{type BiCompF}

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
pub type Bifunctor(f, a, b, c, d, fab, fcd) {
  Bifunctor(bimap: fn(fn(a) -> c, fn(b) -> d) -> fn(fab) -> fcd)
}

/// Default function `first` for a given Bifunctor instance.
/// ### Examples
/// ```gleam
/// let first_show =
///     int.to_string
///     |> {
///         pair_bifunctor()
///         |> first
///     }
///
/// first_show(Pair(8, 9))
/// // -> Pair("8", 9)
/// ```
pub fn first(
  bifunctor: Bifunctor(f, a, b, c, b, fab, fcb),
) -> fn(fn(a) -> c) -> fn(fab) -> fcb {
  fn(g) { bifunctor.bimap(g, cat.id) }
}

/// Default function `second` for a given Bifunctor instance.
/// ### Examples
/// ```gleam
/// let second_show = second(either_bifunctor())(int.to_string)
///
/// Left(8)
/// |> second_show
/// // -> Left(8)
/// Right(9)
/// |> second_show
/// // -> Right("9")
/// ```
pub fn second(
  bifunctor: Bifunctor(f, a, b, a, d, fab, fad),
) -> fn(fn(b) -> d) -> fn(fab) -> fad {
  fn(h) { bifunctor.bimap(cat.id, h) }
}

/// Composition of a `Bifunctor` with `2 Functors`.
/// ```
/// // Haskell instance
/// instance (Bifunctor bf, Functor fu, Functor gu) =>
///     Bifunctor (BiComp bf fu gu) where
///         bimap f1 f2 (BiComp x) = BiComp ((bimap (fmap f1) (fmap f2)) x)
/// ```
/// ### Examples
/// ```gleam
/// Right(Identity(3))
/// |> bifunctor_compose(either_bifunctor(), const_functor(), identity_functor())
///   .bimap(fn(_) { panic }, fn(x) { x % 2 == 0 })
/// // -> Right(Identity(False))
/// ```
pub fn bifunctor_compose(
  bf_instance: Bifunctor(bf, fua, gub, fuc, gud, bifgab, bifgcd),
  fu_instance: Functor(fu, a, c, fua, fuc),
  gu_instance: Functor(gu, b, d, gub, gud),
) -> Bifunctor(BiCompF(bf, fu, gu), a, b, c, d, bifgab, bifgcd) {
  Bifunctor(bimap: fn(f1: fn(a) -> c, f2: fn(b) -> d) {
    fn(x: bifgab) -> bifgcd {
      bf_instance.bimap(fu_instance.fmap(f1), gu_instance.fmap(f2))(x)
    }
  })
}
