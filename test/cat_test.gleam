//// Test module for cat.gleam

import cat
import gleam/int
import gleam/list
import gleam/option
import gleeunit
import gleeunit/should

pub fn main() {
  gleeunit.main()
}

/// Testing the identity function.
pub fn identity_test() {
  cat.id(2)
  |> should.equal(2)

  cat.id("abc")
  |> should.equal("abc")

  cat.id(True)
  |> should.equal(True)
}

/// Testing the composition function.
pub fn composition_test() {
  let y = fn(x: Int) { int.to_string(x) }
  let z = fn(s: String) { s == "28" }
  let h = cat.compose(z, y)

  h(28)
  |> should.equal(True)

  h(29)
  |> should.equal(False)
}

/// Testing that the composition function obeys the id laws.
pub fn composition_rules_test() {
  let f = fn(x: Int) { x * 5 }

  list.map(list.range(0, 100), fn(i) {
    cat.compose(cat.id, f)(i)
    |> should.equal(f(i))
  })

  list.map(list.range(0, 100), fn(i) {
    cat.compose(f, cat.id)(i)
    |> should.equal(f(i))
  })
}

/// Testig unit function.
pub fn unit_function_test() {
  cat.unit(5)
  |> should.equal(Nil)

  cat.unit("abc")
  |> should.equal(Nil)
}

/// Testing product and coproduct factorizers.
pub fn factorizers_test() {
  let p = fn(x: Int) { x }
  let q = fn(_: Int) { True }
  let m = cat.product_factorizer(p, q)

  m(7)
  |> should.equal(cat.Pair(7, True))

  let i = fn(x: Int) { #(x, True) }
  let j = fn(x: Bool) { #(9, x) }
  let m = cat.coproduct_factorizer(i, j)

  m(cat.Left(2))
  |> should.equal(#(2, True))

  m(cat.Right(False))
  |> should.equal(#(9, False))
}

/// Testing pair_to_tuple and tuple_to_pair.
pub fn pair_test() {
  cat.pair_to_tuple(cat.Pair(7, 8))
  |> should.equal(#(7, 8))

  cat.tuple_to_pair(#([1, 2, 3], "abc"))
  |> should.equal(cat.Pair([1, 2, 3], "abc"))
}

/// Testing maybe_to_option and option_to_maybe.
pub fn maybe_test() {
  cat.maybe_to_option(cat.Nothing)
  |> should.equal(option.None)

  cat.maybe_to_option(cat.Just(8))
  |> should.equal(option.Some(8))

  cat.option_to_maybe(option.None)
  |> should.equal(cat.Nothing)

  cat.option_to_maybe(option.Some("a"))
  |> should.equal(cat.Just("a"))
}
