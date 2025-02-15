//// `Bifunctor` type {minimal implementation - `bimap`}. \
//// Default functions: `first` and `second` (defined in terms of bimap). \
//// Bifunctor `composition`.

import cat.{type Either, type Pair, Left, Pair, Right}
import cat/functor.{type Functor, Functor}

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

/// Phantom type for `Tuple Bifunctor`.
pub type TupleBF

/// `Tuple Bifunctor`.
/// ### Examples
/// ```gleam
/// #(6, False)
/// |> tuple_bifunctor().bimap(fn(x) { [x] }, fn(b) { bool.to_string(b) })()
/// // -> #([6], "False")
/// ```
pub fn tuple_bifunctor() -> Bifunctor(TupleBF, a, b, c, d, #(a, b), #(c, d)) {
  Bifunctor(bimap: fn(g: fn(a) -> c, h: fn(b) -> d) -> fn(#(a, b)) -> #(c, d) {
    fn(t: #(a, b)) { #(g(t.0), h(t.1)) }
  })
}

/// Phantom type for `Pair Bifunctor`.
pub type PairBF

/// `Pair Bifunctor`.
/// ### Examples
/// ```gleam
/// Pair(2, 3)
/// |> pair_bifunctor().bimap(fn(x) { x % 3 }, int.to_string)()
/// // -> Pair(2, "3")
/// ```
pub fn pair_bifunctor() -> Bifunctor(PairBF, a, b, c, d, Pair(a, b), Pair(c, d)) {
  Bifunctor(bimap: fn(g: fn(a) -> c, h: fn(b) -> d) -> fn(Pair(a, b)) ->
    Pair(c, d) {
    fn(t: Pair(a, b)) { Pair(g(t.fst), h(t.snd)) }
  })
}

/// Phantom type for `Either Bifunctor`.
pub type EitherBF

/// `Either Bifunctor`.
/// ### Examples
/// ```gleam
/// let show_or_double = either_bifunctor().bimap(int.to_string, fn(x) { x * 2 })
/// 
/// Left(10)
/// |> show_or_double()
/// // -> should.equal(cat.Left("10"))
/// Right(10)
/// |> show_or_double()
/// // -> Right(20)
/// ```
pub fn either_bifunctor() -> Bifunctor(
  EitherBF,
  a,
  b,
  c,
  d,
  Either(a, b),
  Either(c, d),
) {
  Bifunctor(bimap: fn(g: fn(a) -> c, h: fn(b) -> d) -> fn(Either(a, b)) ->
    Either(c, d) {
    fn(e: Either(a, b)) {
      case e {
        Left(x) -> Left(g(x))
        Right(y) -> Right(h(y))
      }
    }
  })
}

/// Bifunctor composition type. 
/// ```
/// newtype BiComp bf fu gu a b = BiComp (bf (fu a ) (gu b))
/// ```
pub type BiComp(bf, fu, gu, a, b, fua, gub, bifgab) {
  // fua = fu(a)
  // gub = gu(b)
  // bifgab = bf(fua, gub)
  BiComp(bifgab)
}

/// Phantom type for bifunctor composition.
pub type BiCompF(bf, fu, gu)

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
