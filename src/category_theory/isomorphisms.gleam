//// This module contains various isomorphisms (morphisms that are invertible).
//// Algebra on Types (Void = 0, Nil = 1, Bool = 2, Either(a, b) = a + b, Pair(a, b) = a * b, Maybe(a) = 1 + a)

import category_theory.{
  type Either, type Maybe, type Pair, type Void, Just, Left, Nothing, Pair,
  Right,
}

/// Commutativity `up to isomorphism` for Pair. \
/// __a * b = b * a__
/// ### Examples
/// ```gleam
/// swap(Pair(5, "abc"))
/// // -> Pair("abc", 5)
/// ```
pub fn swap(p: Pair(a, b)) -> Pair(b, a) {
  let Pair(x, y) = p
  Pair(y, x)
}

/// Commutativity `up to isomorphism` for Either. \
/// __a + b = b + a__
/// ### Examples
/// ```gleam
/// swap(Left(5))
/// // -> Right(5)
/// swap(Right("abc"))
/// // -> Left("abc")
/// ```
pub fn switch(e: Either(a, b)) -> Either(b, a) {
  case e {
    Left(x) -> Right(x)
    Right(y) -> Left(y)
  }
}

/// Morphism from `(a, ())` to `a`. \
/// __a * 1 = a__
pub fn rho(p: Pair(a, Nil)) -> a {
  p.fst
}

/// Inverse morphism from `a` to `(a, ())`. \
/// __a = a * 1__
pub fn rho_inv(x: a) -> Pair(a, Nil) {
  Pair(x, Nil)
}

/// Morphism from `Either(a, Void)` to `a`. \
/// __a + 0 = a__
pub fn psi(e: Either(a, Void)) -> a {
  case e {
    Left(x) -> x
    Right(_) -> panic
  }
}

/// Inverse morphism from `a` to `Either(a, Void)`. \
/// __a = a + 0__
pub fn psi_inv(x: a) -> Either(a, Void) {
  Left(x)
}

/// Associativity `up to isomorphism` of nested Pairs. \
/// __a * (b * c) = (a * b) * c__
pub fn alpha(p: Pair(a, Pair(b, c))) -> Pair(Pair(a, b), c) {
  let Pair(x, Pair(y, z)) = p
  Pair(Pair(x, y), z)
}

/// Inverse associativity `up to isomorphism` of nested Pairs. \
/// __(a * b) * c = a * (b * c)__
pub fn alpha_inv(p: Pair(Pair(a, b), c)) -> Pair(a, Pair(b, c)) {
  let Pair(Pair(x, y), z) = p
  Pair(x, Pair(y, z))
}

/// Associativity `up to isomorphism` of nested Eithers. \
/// __a + (b + c) = (a + b) + c__
pub fn beta(e1: Either(a, Either(b, c))) -> Either(Either(a, b), c) {
  case e1 {
    Left(x) -> Left(Left(x))
    Right(e2) ->
      case e2 {
        Left(y) -> Left(Right(y))
        Right(z) -> Right(z)
      }
  }
}

/// Inverse associativity `up to isomorphism` of nested Eithers. \
/// __(a + b) + c = a + (b + c)__
pub fn beta_inv(e1: Either(Either(a, b), c)) -> Either(a, Either(b, c)) {
  case e1 {
    Left(e2) ->
      case e2 {
        Left(x) -> Left(x)
        Right(y) -> Right(Left(y))
      }
    Right(z) -> Right(Right(z))
  }
}

/// Distributivity `up to isomorphism`. \
/// __a * (b + c) = a * b + a * c__
pub fn product_to_sum(
  p: Pair(a, Either(b, c)),
) -> Either(Pair(a, b), Pair(a, c)) {
  let Pair(x, e) = p
  case e {
    Left(y) -> Left(Pair(x, y))
    Right(z) -> Right(Pair(x, z))
  }
}

/// Inverse distributivity `up to isomorphism`. \
/// __a * b + a * c = a * (b + c)__
pub fn sum_to_product(
  e: Either(Pair(a, b), Pair(a, c)),
) -> Pair(a, Either(b, c)) {
  case e {
    Left(Pair(x, y)) -> Pair(x, Left(y))
    Right(Pair(x, z)) -> Pair(x, Right(z))
  }
}

/// Morphism from `Maybe(a)` to `Either(Nil, a)`. \
/// __1 + a__
pub fn omega(m: Maybe(a)) -> Either(Nil, a) {
  case m {
    Nothing -> Left(Nil)
    Just(x) -> Right(x)
  }
}

/// Inverse morphism from `Either(Nil, a)` to `Maybe(a)`. \
/// __1 + a__
pub fn omega_inv(e: Either(Nil, a)) -> Maybe(a) {
  case e {
    Left(Nil) -> Nothing
    Right(x) -> Just(x)
  }
}

/// Morphism from `Either(a, a)` to `Pair(Bool, a)`. \
/// __a + a = 2 * a__
pub fn delta(e: Either(a, a)) -> Pair(Bool, a) {
  case e {
    Left(x) -> Pair(False, x)
    Right(x) -> Pair(True, x)
  }
}

/// Morphism from `Pair(Bool, a)` to `Either(a, a)`. \
/// __2 * a = a + a__
pub fn delta_inv(p: Pair(Bool, a)) -> Either(a, a) {
  case p {
    Pair(False, x) -> Left(x)
    Pair(True, x) -> Right(x)
  }
}
