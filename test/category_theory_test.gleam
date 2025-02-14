import category_theory as ct
import gleam/int
import gleam/list
import gleam/option
import gleeunit
import gleeunit/should

pub fn main() {
  gleeunit.main()
}

/// Useful function for testing, generating a list that starts from the first parameter and ends at the second.
/// ### Examples
/// ```gleam
/// range(0, 3)
/// // -> [0, 1, 2, 3]
/// range(5, 9)
/// // -> [5, 6, 7, 8, 9]
/// ```
fn range(start: Int, finish: Int) -> List(Int) {
  case finish - start {
    0 -> [start]
    _ -> [start, ..range(start + 1, finish)]
  }
}

/// Testing the identity function.
pub fn identity_test() {
  ct.id(2)
  |> should.equal(2)

  ct.id("abc")
  |> should.equal("abc")

  ct.id(True)
  |> should.equal(True)
}

/// Testing the composition function.
pub fn composition_test() {
  let y = fn(x: Int) { int.to_string(x) }
  let z = fn(s: String) { s == "28" }
  let h = ct.compose(z, y)

  h(28)
  |> should.equal(True)

  h(29)
  |> should.equal(False)
}

/// Testing that the composition function obeys the id laws.
pub fn composition_rules_test() {
  let f = fn(x: Int) { x * 5 }

  list.map(range(0, 100), fn(i) {
    ct.compose(ct.id, f)(i)
    |> should.equal(f(i))
  })

  list.map(range(0, 100), fn(i) {
    ct.compose(f, ct.id)(i)
    |> should.equal(f(i))
  })
}

/// Testig unit function.
pub fn unit_function_test() {
  ct.unit(5)
  |> should.equal(Nil)

  ct.unit("abc")
  |> should.equal(Nil)
}

/// Testing product and coproduct factorizers.
pub fn factorizers_test() {
  let p = fn(x: Int) { x }
  let q = fn(_: Int) { True }
  let m = ct.product_factorizer(p, q)

  m(7)
  |> should.equal(ct.Pair(7, True))

  let i = fn(x: Int) { #(x, True) }
  let j = fn(x: Bool) { #(9, x) }
  let m = ct.coproduct_factorizer(i, j)

  m(ct.Left(2))
  |> should.equal(#(2, True))

  m(ct.Right(False))
  |> should.equal(#(9, False))
}

/// Testing pair_to_tuple and tuple_to_pair.
pub fn pair_test() {
  ct.pair_to_tuple(ct.Pair(7, 8))
  |> should.equal(#(7, 8))

  ct.tuple_to_pair(#([1, 2, 3], "abc"))
  |> should.equal(ct.Pair([1, 2, 3], "abc"))
}

/// Testing maybe_to_option and option_to_maybe.
pub fn maybe_test() {
  ct.maybe_to_option(ct.Nothing)
  |> should.equal(option.None)

  ct.maybe_to_option(ct.Just(8))
  |> should.equal(option.Some(8))

  ct.option_to_maybe(option.None)
  |> should.equal(ct.Nothing)

  ct.option_to_maybe(option.Some("a"))
  |> should.equal(ct.Just("a"))
}
