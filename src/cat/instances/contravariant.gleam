//// `Op type` and its Contravariant instance.

import cat
import cat/contravariant.{type Contravariant, Contravariant}

/// Type for `reverse` functions.
/// ```
/// type Op r a = a -> r
/// ```
/// ### Examples
/// ```gleam
/// let o = Op(fn(x) { x % 2 == 1 })
/// o.apply(6)
/// // -> False
/// ```
pub type Op(r, a) {
  Op(apply: fn(a) -> r)
}

/// Phantom type for `Op Contravariant`.
pub type OpC(r)

/// `Op Contravariant Instance`.
/// ```
/// // Haskell implementation
/// instance Contravariant (Op r) where
///     contramap :: (b -> a) -> Op r a -> Op r b
///     contramap f g = g∘. f
/// ```
/// ### Examples
/// ```gleam
/// let f = fn(b) {
///     case b {
///       True -> 2
///       False -> 4
///     }
///  }
/// let original = Op(fn(x) { int.to_string(x * 2) })
/// let result = op_contravariant().contramap(f)(original)
/// result.apply(False)
/// // -> "8"
/// ```
pub fn op_contravariant() -> Contravariant(OpC(r), a, b, Op(r, a), Op(r, b)) {
  Contravariant(contramap: fn(f: fn(a) -> b) {
    fn(g: Op(r, b)) -> Op(r, a) { Op(cat.flip(cat.compose)(f, g.apply)) }
  })
}
