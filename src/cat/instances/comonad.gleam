//// `Comonad` instances: Identity, NonEmpty, Tuple, Pair, and Reader.

import cat.{type Identity, Identity}
import cat/comonad.{type Comonad, Comonad}
import cat/instances/types.{type IdentityF}

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
