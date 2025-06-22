//// `Bifunctor` instances: Tuple, Pair, and Either.

import cat.{type Either, type Pair, Left, Pair, Right}
import cat/bifunctor.{type Bifunctor, Bifunctor}
import cat/instances/types.{type EitherBF, type PairBF, type TupleBF}

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
