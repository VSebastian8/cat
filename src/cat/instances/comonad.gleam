//// `Comonad` instances: Identity, NonEmpty, Tuple, Pair, and Reader.

import cat.{type Identity, type NonEmpty, Identity, Leaf, Next}
import cat/comonad.{type Comonad, Comonad}
import cat/instances/types.{type IdentityF, type NonEmptyF}

/// Comonad instance for `Identity`.
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
    extend: fn(f, idx) { Identity(f(idx)) },
  )
}

/// Comonad instance for `NonEmpty`.
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
    extend: fn(f, wa) { Leaf(f(wa)) },
  )
}
