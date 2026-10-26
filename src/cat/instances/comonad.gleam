//// `Comonad` instances: Identity, NonEmpty, Tuple, Pair, and Reader.

import cat.{type Identity, type NonEmpty, Identity, Leaf, Next}
import cat/comonad.{type Comonad, Comonad}
import cat/instances/types.{type IdentityF, type NonEmptyF, type TupleF}

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

fn non_empty_duplicate(wa: NonEmpty(a)) -> NonEmpty(NonEmpty(a)) {
  case wa {
    Leaf(_) -> Leaf(wa)
    Next(_, xs) -> Next(wa, non_empty_duplicate(xs))
  }
}

fn non_empty_extend(wa: NonEmpty(a), f: fn(NonEmpty(a)) -> b) -> NonEmpty(b) {
  case wa {
    Leaf(_) -> Leaf(f(wa))
    Next(_, xs) -> Next(f(wa), non_empty_extend(xs, f))
  }
}

/// Comonad instance for `NonEmpty`.
/// ### Examples
/// ```gleam
/// Next("a", Next("b", Leaf("c")))
/// |> non_empty_comonad().duplicate()
/// // -> Next(Next("a", Next("b", Leaf("c"))),
/// //    Next(Next("b", Leaf("c")), 
/// //    Leaf(Leaf("c")))
/// ```
/// ```gleam
/// 
/// fn sum(vec: NonEmpty(Int)) -> Int {
///   case vec {
///     Leaf(x) -> x
///     Next(x, v) -> x + sum(v)
///   }
/// }
/// 
/// Next(1, Next(2, Next(3, Leaf(4))))
/// |> non_empty_comonad().extend(sum)
/// // -> Next(10, Next(9, Next(7, Leaf(4))))
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
    duplicate: non_empty_duplicate,
    extend: non_empty_extend,
  )
}

/// Comonad instance for `Tuple`.
/// ### Examples
/// ```gleam
/// #("hello", 5)
/// |> tuple_comonad().extract()
/// 
/// // -> 5
/// #("hello", 5)
/// |> tuple_comonad().duplicate()
/// // -> #("hello", #("hello", 5))
/// 
/// #("hello", 5)
/// |> tuple_comonad().extend(fn(p: #(String, Int)) { length(p.0) == p.1 })
/// // -> #("hello", True)
/// ```
pub fn tuple_comonad() -> Comonad(
  TupleF(c),
  a,
  b,
  #(c, a),
  #(c, b),
  #(c, #(c, a)),
) {
  Comonad(
    extract: fn(p: #(c, a)) { p.1 },
    duplicate: fn(p: #(c, a)) { #(p.0, p) },
    extend: fn(p: #(c, a), f: fn(#(c, a)) -> b) { #(p.0, f(p)) },
  )
}
