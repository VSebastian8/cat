//// Test module for cat/monoid.gleam

import cat/instances/monoid as mono
import cat/monoid.{Monoid, mconcat}
import gleam/option
import gleeunit/should

/// Testing the Monoid type: mempty, mappend and mconcat.
pub fn monoid_type_test() {
  let int_sum_monoid = Monoid(mempty: 0, mappend: fn(x: Int, y: Int) { x + y })

  int_sum_monoid.mappend(7, 8)
  |> should.equal(15)

  int_sum_monoid.mappend(4, int_sum_monoid.mempty)
  |> should.equal(4)

  let int_prod_monoid = Monoid(mempty: 1, mappend: fn(x: Int, y: Int) { x * y })

  int_prod_monoid
  |> mconcat([2, 3, int_prod_monoid.mempty, 4, int_prod_monoid.mempty])
  |> int_prod_monoid.mappend(10)
  |> should.equal(240)
}

/// Testing the unit monoid.
pub fn monoid_unit_test() {
  mono.unit_monoid().mappend(mono.unit_monoid().mempty, Nil)
  |> should.equal(Nil)
}

/// Testing the (Bool, &&) monoid.
pub fn monoid_all_test() {
  let bool_and_monoid = mono.all_monoid()

  True
  |> bool_and_monoid.mappend(False)
  |> bool_and_monoid.mappend(bool_and_monoid.mempty)
  |> should.equal(False)
}

/// Testing the (Bool, ||) monoid.
pub fn monoid_any_test() {
  let bool_or_monoid = mono.any_monoid()

  False
  |> bool_or_monoid.mappend(False)
  |> bool_or_monoid.mappend(bool_or_monoid.mempty)
  |> should.equal(False)
}

/// Testing the list monoid.
pub fn monoid_list_test() {
  let mono_list = mono.list_monoid()

  [1, 2]
  |> mono_list.mappend([3, 4, 5])
  |> mono_list.mappend(mono_list.mempty)
  |> mono_list.mappend([6])
  |> should.equal([1, 2, 3, 4, 5, 6])
}

/// Testing the option monoid.
pub fn monoid_option_test() {
  let mono_string =
    Monoid(mempty: "", mappend: fn(x: String, y: String) -> String { x <> y })
  let mono_maybe = mono.option_monoid(mono_string)

  option.Some("ab")
  |> mono_maybe.mappend(option.Some("cd"))
  |> should.equal(option.Some("abcd"))

  mono_maybe.mappend(option.Some("abc"), mono_maybe.mempty)
  |> should.equal(option.None)
}

/// Testing the tuple monoid.
pub fn monoid_tuple_test() {
  let mono_bool = mono.all_monoid()
  let mono_list = mono.list_monoid()

  let mono_all_list = mono.tuple_monoid(mono_bool, mono_list)
  #(True, [1, 2])
  |> mono_all_list.mappend(#(True, [3]))
  |> mono_all_list.mappend(mono_all_list.mempty)
  |> mono_all_list.mappend(#(False, []))
  |> should.equal(#(False, [1, 2, 3]))
}
