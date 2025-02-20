//// Test module for cat/applicative.gleam

import cat/applicative.{apply, pure}
import cat/instances/applicative as app
import cat/instances/functor as fun
import gleam/int
import gleam/option
import gleeunit/should

/// Testing the option applicative instance.
pub fn option_app_test() {
  9
  |> { app.option_applicative() |> pure() }
  |> should.equal(option.Some(9))

  let option_f =
    int.to_string
    |> { app.option_applicative() |> pure() }
    |> { app.option_applicative() |> apply() }

  option.None |> option_f |> should.equal(option.None)
  option.Some(12) |> option_f |> should.equal(option.Some("12"))
}

/// Testing the list applicative instance.
pub fn list_app_test() {
  [1, 2, 3]
  |> {
    [fn(x) { x * 2 }, fn(x) { x + 10 }]
    |> apply(app.list_applicative())
  }
  |> should.equal([2, 4, 6, 11, 12, 13])
}

/// Testing applicative of functor.
pub fn option_list_test() {
  [option.Some(1), option.None, option.Some(3)]
  |> {
    [fn(x) { x * 2 }, fn(x) { x + 10 }]
    |> fun.list_functor().fmap(fun.option_functor().fmap)
    |> apply(app.list_applicative())
  }
  |> should.equal([
    option.Some(2),
    option.None,
    option.Some(6),
    option.Some(11),
    option.None,
    option.Some(13),
  ])
}
