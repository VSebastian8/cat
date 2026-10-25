//// `Comonad` instances: Identity, NonEmpty, Tuple, Pair, and Reader.

import cat.{type Identity, type NonEmpty, Identity, Leaf, Next}
import cat/comonad.{type Comonad, Comonad}
import cat/instances/types.{type IdentityF, type NonEmptyF}

/// Comonad instance for `Identity`.
/// ### Examples
/// ```gleam
/// let double = fn(id: Identity(Int)) -> Int {
///   let Identity(x) = id
///   x * 2
/// }
/// Identity(5)
/// |> identity_comonad().extend(double)
/// // -> Identity(10)
/// ```
pub fn identity_comonad() -> Comonad(
  IdentityF,
  a,
  b,
  Identity(a),
  Identity(b),
  Identity(Identity(a)),
) {
  Comonad(
    extract: fn(idx) {
      let Identity(x) = idx
      x
    },
    duplicate: fn(idx) { Identity(idx) },
    extend: fn(idx, f) { Identity(f(idx)) },
  )
}

/// Comonad instance for `NonEmpty`.
/// ### Examples
/// ```
/// fn sum(vec: NonEmpty(Int)) -> Int {
///   case vec {
///     Leaf(x) -> x
///     Next(x, v) -> x + sum(v)
///   }
/// }
/// 
/// Next(1, Next(2, Leaf(3)))
/// |> non_empty_comonad().extend(sum)
/// |> non_empty_comonad().extract()
/// // -> 6
/// ```
pub fn non_empty_comonad() -> Comonad(
  NonEmptyF,
  a,
  b,
  NonEmpty(a),
  NonEmpty(b),
  NonEmpty(NonEmpty(a)),
) {
  Comonad(
    extract: fn(wa) {
      case wa {
        Leaf(x) -> x
        Next(x, _) -> x
      }
    },
    duplicate: fn(wa) { Leaf(wa) },
    extend: fn(wa, f) { Leaf(f(wa)) },
  )
}
