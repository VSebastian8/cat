//// `Basic category concepts`: composition, identity, Void, unit, option (Maybe), product (Pair), coproduct (Either), Identity, and Const.

import gleam/io
import gleam/option.{type Option, None, Some}

/// The `identity function` is a `unit of composition`.
/// ```
/// id :: a -> a
/// id a = a
/// ```
/// It follows the identity conditions:
/// - f . id == f
/// - id . f == f
/// ### Examples
/// ```gleam
/// id(3)
/// // -> 3
/// id("abc")
/// // -> "abc"
/// ```
pub fn id(x: a) -> a {
  x
}

/// Given a function `f` that takes an argument of type A and returns a B, and another function `g` that takes a B and returns a C, you can `compose` them by `passing the result of f to g`. 
/// ```
/// (.) :: (b -> c) -> (a -> b) -> (a -> c)
/// (g . f) x = f (g x)
/// ```
/// Properties of composition:
/// - Associativity h . (g . f) == (h . g) . f == h . g . f
/// - Identity see [`id`](#id) for more info
/// ### Examples
/// ```gleam
/// let f = fn(x: Int) { int.to_string(x) }
/// let g = fn(s: String) { s == "28" }
/// let h = compose(g, f)
/// // -> h takes an int, transforms it into a string, then compares it to "28" and returns a bool
/// ``` 
pub fn compose(g: fn(b) -> c, f: fn(a) -> b) -> fn(a) -> c {
  fn(x: a) { g(f(x)) }
}

/// A type corresponding to an `empty set`. It is `not inhabited` by any values.
pub type Void {
  Void(Void)
}

/// A function that can `never` be called. It is polymorphic in the return type. 
pub fn absurd(_: Void) -> a {
  panic
}

/// A function from any type to a unit (Nil in gleam).
/// ```
/// unit :: a -> ()
/// unit _ = ()
/// ```
/// ### Examples
/// ```gleam
/// unit(42)
/// // -> Nil
/// unit(True)
/// // -> Nil
/// ```
pub fn unit(_: t) {
  Nil
}

/// Canonical implementation of a `product` (tuple).
/// Examples
/// ```gleam
/// let even_to_string = fn(x: Int) -> Pair(String, Bool) {
///   Pair(int.to_string(x), x % 2 == 0)
/// }
/// even_to_string(82).fst
/// // -> "82"
/// even_to_string(82).snd
/// // -> True
/// even_to_string(83).snd
/// // -> False
/// ```
pub type Pair(a, b) {
  Pair(fst: a, snd: b)
}

/// Produces the factorizing function from a `candidate` c with `two projections` p and q to the best product (tuple / pair). \
/// Property: p and q can be `reconstructed` from the canonical product  \
/// With m = product_factorizer(p, q), we have:
/// - p(x) = m(x).fst
/// - q(x) = m(x).snd
/// ### Examples
/// ```gleam
/// // Given the candidate Int with two projections to Int and Bool
/// let p = fn(x: Int) {x}
/// let q = fn(_: Int) {True}
/// // We show that Pair(Int, Bool) is a better product by finding the mapping m:
/// let m = product_factorizer(p, q)
/// m(7)
/// // -> Pair(7, True)  
/// ```
pub fn product_factorizer(p: fn(c) -> a, q: fn(c) -> b) -> fn(c) -> Pair(a, b) {
  fn(x) { Pair(fst: p(x), snd: q(x)) }
}

/// Canonical implementation of a `coproduct` (sum type).
/// ```
/// data Either a b = Left a | Right b
/// ```
/// ### Examples
/// ```gleam
/// let check_positive = fn(x: Int) -> Either(Int, String) {
///   case x >= 0 {
///     True -> Left(x)
///     False -> Right("negative number")
///   }
/// }
/// check_positive(12)
/// // -> Left(12)
/// check_positive(-3)
/// // -> Right("negative number")
/// ```
pub type Either(a, b) {
  Left(a)
  Right(b)
}

/// Produces the factorizing function from a `candidate` c with `two injections` i and j to the best coproduct (either). \
/// Property: i and j can be `reconstructed` from the canonical coproduct e  \
/// With m = coproduct_factorizer(i, j), we have:
/// - i(x) = m(Left(x))
/// - j(x) = m(Right(x))
/// ### Examples
/// ```gleam
/// // Given the candidate #(Int, Bool) with two injections from Int and Bool
/// let i = fn(x: Int) {#(x, True)}
/// let j = fn(x: Bool) {#(9, x)}
/// // We show that Either(Int, Bool) is a better coproduct by finding the mapping m:
/// let m = coproduct_factorizer(i, j)
/// m(Left(2))
/// // -> #(2, True)  
/// m(Right(False))
/// // -> #(9, False)  
/// ```
pub fn coproduct_factorizer(
  i: fn(a) -> c,
  j: fn(b) -> c,
) -> fn(Either(a, b)) -> c {
  fn(e) {
    case e {
      Left(a) -> i(a)
      Right(b) -> j(b)
    }
  }
}

/// Converts from `Pair` to gleam `Tuple`.
/// ### Examples
/// ```gleam
/// pair_to_tuple(Pair(2, True))
/// // -> #(2, True)
/// ```
pub fn pair_to_tuple(p: Pair(a, b)) -> #(a, b) {
  #(p.fst, p.snd)
}

/// Converts from gleam `Tuple` to `Pair`.
/// ### Examples
/// ```gleam
/// tuple_to_pair(#(2, True))
/// // -> Pair(2, True)
/// ```
pub fn tuple_to_pair(t: #(a, b)) -> Pair(a, b) {
  Pair(t.0, t.1)
}

/// `Maybe` type from Haskell (`Option` in gleam).
/// ```
/// data Maybe = Nothing | Just a
/// // Equivalent: Sum type between `unit` and `a`
/// type Maybe = Either () a
/// ```
/// ### Examples
/// ```gleam
/// let safe_div = fn(a, b) {
///   case b != 0.0 {
///     True -> Just(a /. b)
///     False -> Nothing
///   }
/// }
/// safe_div(3.0, 4.0)
/// // -> Just(0,75)
/// safe_div(3.0, 0.0)
/// // -> Nothing
/// ```
pub type Maybe(a) {
  Nothing
  Just(a)
}

/// `Composition` for the Maybe type 
/// ### Examples
/// ```gleam
/// let safe_reciprocal = fn(x) {
///   case x != 0.0 {
///     True -> Just(1.0 /. x)
///     False -> Nothing
///   }
/// }
/// let safe_root = fn(x) {
///   case x >=. 0.0 {
///     True -> Just(x |> float.square_root() |> result.unwrap(0.0))
///     False -> Nothing
///   }
/// }
/// let safe_reciprocal_root = maybe_compose(safe_reciprocal, safe_root)
/// // -> a function that calculates sqrt(1/x)
/// safe_reciprocal_root(0.25)
/// // -> Just(2.0)
/// safe_reciprocal_root(0.0)
/// // -> Nothing
/// safe_reciprocal_root(-2.0)
/// // -> Nothing
/// ```
pub fn maybe_compose(
  m1: fn(a) -> Maybe(b),
  m2: fn(b) -> Maybe(c),
) -> fn(a) -> Maybe(c) {
  fn(x) {
    case m1(x) {
      Nothing -> Nothing
      Just(y) -> m2(y)
    }
  }
}

/// The `idenitity morphism` for the Maybe type.
/// ### Examples
/// ```gleam
/// maybe_id(25)
/// // -> Just(25)
/// maybe_id(Nothing)
/// // -> Just(Nothing)
/// ```
pub fn maybe_id(x: a) -> Maybe(a) {
  Just(x)
}

/// Converts from `Maybe` to gleam `Option`.
/// ### Examples
/// ```gleam
/// maybe_to_option(Nothing)
/// // -> None
/// maybe_to_option(Just(2))
/// // -> Some(2)
/// ```
pub fn maybe_to_option(m: Maybe(a)) -> Option(a) {
  case m {
    Nothing -> None
    Just(x) -> Some(x)
  }
}

/// Converts from gleam `Option` to `Maybe`.
/// ### Examples
/// ```gleam
/// option_to_maybe(None)
/// // -> Nothing
/// option_to_maybe(Some(2))
/// // -> Just(2)
/// ```
pub fn option_to_maybe(o: Option(a)) -> Maybe(a) {
  case o {
    None -> Nothing
    Some(x) -> Just(x)
  }
}

pub type List(a) {
  // Nil is taken by gleam (unit type)
  Null
  // Recursive type definition
  Cons(List(a))
}

/// `Identity` type from Haskell
/// ```
/// newtype Identity a = Identity a
/// ```
/// ### Examples
/// ```gleam
/// Identity(8)
/// Identity("abc")
/// ```
pub type Identity(a) {
  Identity(a)
}

/// `Const` type from Haskell.
/// ```
/// data Const c a = Const c
/// ```
/// Only the first parameter affects the type, the second is ignore. \
/// In gleam, we say that `a` is a `phantom type`.
/// ### Examples
/// ```gleam
/// let x: Const(Int, Bool) = Const(7)
/// let y: Const(String, String) = Const("abc")
/// ```
pub type Const(c, a) {
  Const(c)
}

pub fn main() {
  io.println("Category Theory!")
}
