//// Test module for cat/applicative.gleam

import cat
import cat/applicative
import cat/instances/applicative as app
import cat/instances/functor as fun
import cat/instances/monoid as mono
import gleam/int
import gleam/option
import gleeunit/should

/// Testing the left applicative operator
pub fn left_app_test() {
  let ap_left =
    applicative.left(app.option_applicative(), app.option_applicative())

  ap_left(option.Some(2), option.Some(3))
  |> should.equal(option.Some(2))
  ap_left(option.None, option.Some(3))
  |> should.equal(option.None)
  ap_left(option.Some(2), option.None)
  |> should.equal(option.None)
  ap_left(option.Some(2), ap_left(option.Some(3), option.Some(4)))
  |> should.equal(option.Some(2))
  ap_left(option.Some(2), ap_left(option.None, option.Some(4)))
  |> should.equal(option.None)
  ap_left(option.Some(2), ap_left(option.Some(3), option.None))
  |> should.equal(option.None)
}

pub fn right_app_test() {
  let ap_right =
    applicative.right(app.option_applicative(), app.option_applicative())

  ap_right(option.Some(2), option.Some(3))
  |> should.equal(option.Some(3))
  ap_right(option.None, option.Some(3))
  |> should.equal(option.None)
  ap_right(option.Some(2), option.None)
  |> should.equal(option.None)
  ap_right(option.Some(2), ap_right(option.Some(3), option.Some(4)))
  |> should.equal(option.Some(4))
  ap_right(option.Some(2), ap_right(option.None, option.Some(4)))
  |> should.equal(option.None)
  ap_right(option.Some(2), ap_right(option.Some(3), option.None))
  |> should.equal(option.None)
}

pub fn chain_app_test() {
  let ap_left =
    applicative.left(app.option_applicative(), app.option_applicative())
  let ap_right =
    applicative.right(app.option_applicative(), app.option_applicative())

  ap_left(option.Some("good"), option.Some(True))
  |> should.equal(option.Some("good"))
  ap_right(option.Some(7), option.Some("good"))
  |> should.equal(option.Some("good"))
  ap_right(option.Some(7), ap_left(option.Some("good"), option.Some(True)))
  |> should.equal(option.Some("good"))
  ap_right(option.None, ap_left(option.Some("good"), option.Some(True)))
  |> should.equal(option.None)
  ap_right(option.Some(7), ap_left(option.Some("good"), option.None))
  |> should.equal(option.None)
  ap_right(option.Some(7), ap_left(option.None, option.Some(True)))
  |> should.equal(option.None)
}

pub fn flip_apply_test() {
  let identity_f =
    fn(x: Int, y: String) { int.to_string(x) <> y }
    |> cat.curry()
    |> app.identity_applicative().pure()

  applicative.flip_apply(app.identity_applicative())(cat.Identity(" apples"))(
    applicative.flip_apply(app.identity_applicative())(cat.Identity(6))(
      identity_f,
    ),
  )
  |> should.equal(cat.Identity("6 apples"))
}

/// Testing the identity applicative instance.
pub fn identity_app_test() {
  let identity_f =
    fn(x: Int, y: String) { int.to_string(x) <> y }
    |> cat.curry()
    |> app.identity_applicative().pure()

  app.identity_applicative().apply(
    app.identity_applicative().apply(identity_f)(cat.Identity(6)),
  )(cat.Identity(" apples"))
  |> should.equal(cat.Identity("6 apples"))
}

/// Testing the option applicative instance.
pub fn option_app_test() {
  9
  |> { app.option_applicative().pure }
  |> should.equal(option.Some(9))

  let option_f =
    int.to_string
    |> { app.option_applicative().pure }
    |> { app.option_applicative().apply }

  option.None |> option_f |> should.equal(option.None)
  option.Some(12) |> option_f |> should.equal(option.Some("12"))
}

/// Testing applicative of functor.
pub fn option_list_test() {
  [option.Some(1), option.None, option.Some(3)]
  |> {
    [fn(x) { x * 2 }, fn(x) { x + 10 }]
    |> fun.list_functor().fmap(fun.option_functor().fmap)
    |> app.list_applicative().apply
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

/// Testing the result applicative instance.
pub fn result_app_test() {
  let resf =
    app.result_applicative().pure(fn(x) { x * 10 })
    |> app.result_applicative().apply
  resf(Ok(7))
  |> should.equal(Ok(70))
  resf(Error("Not a number"))
  |> should.equal(Error("Not a number"))
}

/// Testing the list applicative instance.
pub fn list_app_test() {
  [1, 2, 3]
  |> {
    [fn(x) { x * 2 }, fn(x) { x + 10 }]
    |> app.list_applicative().apply
  }
  |> should.equal([2, 4, 6, 11, 12, 13])
}

// Testing the const monoid => applicative instance.
pub fn const_app_test() {
  {
    app.const_monoid_applicative(mono.all_monoid()).pure(fn(x) { x * 2 })
    // True
    |> app.const_monoid_applicative(mono.any_monoid()).apply
    // ||
  }(app.const_monoid_applicative(mono.all_monoid()).pure(7))
  // False
  |> should.equal(cat.Const(True))
}

// Testing the tuple monoid => applicative instance
pub fn tuple_app_test() {
  let sum = mono.int_sum_monoid()
  {
    {
      fn(x) { fn(y) { x * 10 + y } }
      |> app.tuple_monoid_applicative(sum).pure()
      |> app.tuple_monoid_applicative(sum).apply()
    }(#(3, 7))
    |> app.tuple_monoid_applicative(sum).apply()
  }(#(2, 4))
  |> should.equal(#(5, 74))
}

// Testing the pair monoid => applicative instance
pub fn pair_app_test() {
  let prod = mono.int_prod_monoid()
  {
    {
      fn(x) { fn(y) { x * 10 + y } }
      |> app.pair_monoid_applicative(prod).pure()
      |> app.pair_monoid_applicative(prod).apply()
    }(cat.Pair(3, 9))
    |> app.pair_monoid_applicative(prod).apply()
  }(cat.Pair(4, 1))
  |> should.equal(cat.Pair(12, 91))
}

// Testing the either applicative instance.
pub fn either_app_test() {
  let e_plus =
    fn(x) { x + 2 }
    |> app.either_applicative().pure()
    |> app.either_applicative().apply()

  e_plus(cat.Left("Unexpected"))
  |> should.equal(cat.Left("Unexpected"))

  e_plus(cat.Right(1))
  |> should.equal(cat.Right(3))
}

// Testing the triple monoid, monoid => applicative instance
pub fn triple_app_test() {
  let sum = mono.int_sum_monoid()
  let prod = mono.int_prod_monoid()
  let triple_plus =
    fn(x) { fn(y) { x + y } }
    |> app.triple_monoid_applicative(sum, prod).pure()
    |> app.triple_monoid_applicative(sum, prod).apply()
  // Final instance for binding the generic types:
  let triple = app.triple_monoid_applicative(sum, prod)
  // Applicative function chain:
  triple.apply(triple_plus(#(3, 3, 20)))(#(4, 4, 15))
  |> should.equal(#(7, 12, 35))
}

// Testing the writer applicative instance.
pub fn writer_app_test() {
  let log_plus =
    cat.Writer(fn(x) { x + 2 }, "[plus two]")
    |> app.writer_applicative().apply()

  log_plus(cat.Writer(7, " seven"))
  |> should.equal(cat.Writer(9, "[plus two] seven"))
}

// Testing the reader applicative instance.
pub fn reader_app_test() {
  let rff = cat.Reader(fn(x) { fn(y) { x * y } })
  let rf = cat.Reader(fn(x) { x + 5 })
  let rg = app.reader_applicative().apply(rff)(rf)
  // 2 * (2 + 5)
  rg.apply(2)
  |> should.equal(14)
}

// Testing the function applicative instance.
pub fn function_app_test() {
  let ff = fn(x) { fn(y) { x * y } }
  let f = fn(x) { x + 5 }
  let g = app.function_applicative().apply(ff)(f)
  // 2 * (2 + 5)
  g(2)
  |> should.equal(14)
}
