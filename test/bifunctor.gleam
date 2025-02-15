//// Test module for cat/bifunctor.gleam

import cat
import cat/bifunctor as bif
import gleam/bool
import gleam/int
import gleeunit/should

/// Testing the first function.
pub fn first_test() {
  let first_show =
    int.to_string
    |> {
      bif.pair_bifunctor()
      |> bif.first
    }

  first_show(cat.Pair(8, 9))
  |> should.equal(cat.Pair("8", 9))
}

/// Testing the second function.
pub fn second_test() {
  let second_show = bif.second(bif.either_bifunctor())(int.to_string)

  cat.Left(8)
  |> second_show
  |> should.equal(cat.Left(8))

  cat.Right(9)
  |> second_show
  |> should.equal(cat.Right("9"))
}

/// Testing tuple bifunctor instance.
pub fn tuple_bifunctor_test() {
  #(6, False)
  |> bif.tuple_bifunctor().bimap(fn(x) { [x] }, fn(b) { bool.to_string(b) })()
  |> should.equal(#([6], "False"))
}

/// Testing tuple bifunctor instance.
pub fn pair_bifunctor_test() {
  cat.Pair(2, 3)
  |> bif.pair_bifunctor().bimap(fn(x) { x % 3 }, int.to_string)()
  |> should.equal(cat.Pair(2, "3"))
}

/// Testing either bifunctor instance.
pub fn either_bifunctor_test() {
  let show_or_double =
    bif.either_bifunctor().bimap(int.to_string, fn(x) { x * 2 })

  cat.Left(10)
  |> show_or_double()
  |> should.equal(cat.Left("10"))

  cat.Right(10)
  |> show_or_double()
  |> should.equal(cat.Right(20))
}
