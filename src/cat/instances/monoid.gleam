//// `Monoid` instances: Unit, Bool (All and Any), List, Option, Tuple, Triple, Function.

import cat/monoid.{type Monoid, Monoid}
import gleam/bool
import gleam/list
import gleam/option.{type Option, None, Some}

/// Returns the `canonical implementation` of the `monoid type for Nil` (unit type).
/// ### Examples
/// ```gleam
/// let mono_unit = unit_monoid()
/// mono_unit.mappend(mono_unit.mempty, Nil)
/// // -> Nil
/// ```
pub fn unit_monoid() -> Monoid(Nil) {
  Monoid(mempty: Nil, mappend: fn(_, _) { Nil })
}

/// Monoid instance for Bool with (&&).
/// ### Examples
/// ```gleam
/// let bool_and_monoid = all_monoid()
/// True
/// |> bool_and_monoid.mappend(False)
/// |> bool_and_monoid.mappend(bool_and_monoid.mempty)
/// // -> False
/// ```
pub fn all_monoid() -> Monoid(Bool) {
  Monoid(mempty: True, mappend: bool.and)
}

/// Monoid instance for Bool with (||).
/// ### Examples
/// ```gleam
/// let bool_or_monoid = any_monoid()
/// False
/// |> bool_or_monoid.mappend(False)
/// |> bool_or_monoid.mappend(bool_or_monoid.mempty)
/// // -> False
/// ```
pub fn any_monoid() -> Monoid(Bool) {
  Monoid(mempty: False, mappend: bool.or)
}

/// Returns the `canonical implementation` of the `monoid type for List`.
/// ### Examples
/// ```gleam
/// let mono_list = list_monoid()
/// [1, 2]
/// |> mono_list.mappend([3, 4, 5])
/// |> mono_list.mappend(mono_list.mempty)
/// |> mono_list.mappend([6])
/// // -> [1, 2, 3, 4, 5, 6]
/// ```
pub fn list_monoid() -> Monoid(List(a)) {
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
