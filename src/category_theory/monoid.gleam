//// The Monoid module contains the `Monoid` type with who's minimal implementations are `mempty` and `mappend`. \
//// We also define the `mconcat` function in terms of mempty and mappend. \
//// Finally, this module contains several instances for the monoid type.

/// A monoid is a `set` with a `binary operation` or a a `single object category` with a `set of morphisms` that follow the rules of composition.
/// ```haskell
/// class Monoid m where
///   mempty  :: m
///   mappend :: m -> m -> m
/// ```
/// Laws:
/// - mappend mempty x = x
/// - mappend x mempty = x
/// - mappend x (mappend y z) = mappend (mappend x y) z
/// - mconcat = foldr mappend mempty
/// ### Examples
/// ```gleam
/// let int_sum_monoid = Monoid(mempty: 0, mappend: fn(x: Int, y: Int) { x + y })
/// int_sum_monoid
/// |> mconcat([2, 3, int_sum_monoid.mempty, 4])
/// |> int_sum_monoid.mappend(10)
/// // -> 19
/// let bool_and_monoid = Monoid(mempty: True, mappend: bool.and)
/// True
/// |> bool_and_monoid.mappend(False)
/// |> bool_and_monoid.mappend(bool_and_monoid.mempty)
/// // -> False
/// ```
pub type Monoid(m) {
  Monoid(mempty: m, mappend: fn(m, m) -> m)
}

// Separate function because gleam doesn't allow default implementations for record fields
/// Fold a `list of monoids` using mappend. 
pub fn mconcat(mono: Monoid(m), monoid_list: List(m)) -> m {
  monoid_list |> list.fold(mono.mempty, mono.mappend)
}

import gleam/list
import gleam/option.{type Option, None, Some}

/// Returns the `canonical implementation` of the `monoid type for Nil` (unit type).
/// ### Examples
/// ```gleam
/// mono_unit.mappend(mono_unit.mempty, Nil)
/// // -> Nil
/// ```
pub fn unit_monoid() -> Monoid(Nil) {
  Monoid(mempty: Nil, mappend: fn(_, _) { Nil })
}

/// Returns the `canonical implementation` of the `monoid type for List`.
/// ### Examples
/// ```gleam
/// [1, 2]
/// |> mono_list.mappend([3, 4, 5])
/// |> mono_list.mappend(mono_list.mempty)
/// |> mono_list.mappend([6])
/// // -> [1, 2, 3, 4, 5, 6]
/// ```
pub fn list_monoid() {
  Monoid(mempty: [], mappend: list.append)
}

/// Returns the `canonical implementation` of the `monoid type for Option(a)`. \
/// We must have a Monoid(a) type instance.
/// ### Examples
/// ```gleam
/// let mono_string = Monoid(mempty: "", mappend: fn(x: String, y: String) -> String { x <> y })
/// let mono_maybe = option_monoid(mono_string)
/// 
/// Some("ab")
/// |> mono_maybe.mappend(Some("cd"))
/// // -> Some("abcd")
/// mono_maybe.mappend(Some("abc"), maybe.mempty)
/// // -> None
/// ```
pub fn option_monoid(mono_a: Monoid(a)) -> Monoid(Option(a)) {
  Monoid(mempty: None, mappend: fn(m1: Option(a), m2: Option(a)) -> Option(a) {
    case m1, m2 {
      None, _ -> None
      _, None -> None
      Some(a1), Some(a2) -> Some(mono_a.mappend(a1, a2))
    }
  })
}

/// Returns the `canonical implementation` of the `monoid type for Tuple`. \
/// We must have a Monoid(a) and a Monoid(b) type instance.
pub fn tuple_monoid(mono_a: Monoid(a), mono_b: Monoid(b)) -> Monoid(#(a, b)) {
  Monoid(
    mempty: #(mono_a.mempty, mono_b.mempty),
    mappend: fn(m1: #(a, b), m2: #(a, b)) -> #(a, b) {
      #(mono_a.mappend(m1.0, m2.0), mono_b.mappend(m1.1, m2.1))
    },
  )
}

/// Returns the `canonical implementation` of the `monoid type for Triple`. \
/// We must have a Monoid type instance for a, b, and c.
pub fn triple_monoid(
  mono_a: Monoid(a),
  mono_b: Monoid(b),
  mono_c: Monoid(c),
) -> Monoid(#(a, b, c)) {
  Monoid(
    mempty: #(mono_a.mempty, mono_b.mempty, mono_c.mempty),
    mappend: fn(m1: #(a, b, c), m2: #(a, b, c)) -> #(a, b, c) {
      #(
        mono_a.mappend(m1.0, m2.0),
        mono_b.mappend(m1.1, m2.1),
        mono_c.mappend(m1.2, m2.2),
      )
    },
  )
}

/// Monoid instance for functions where the `result type` must be a Monoid instance.
pub fn function_monoid(mono_b: Monoid(b)) -> Monoid(fn(a) -> b) {
  Monoid(
    mempty: fn(_: a) -> b { mono_b.mempty },
    mappend: fn(f: fn(a) -> b, g: fn(a) -> b) -> fn(a) -> b {
      fn(x: a) { mono_b.mappend(f(x), g(x)) }
    },
  )
}
