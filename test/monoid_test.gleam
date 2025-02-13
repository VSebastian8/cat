import category_theory/monoid as mono
import gleam/bool
import gleam/io
import gleam/option
import gleeunit/should

pub fn monoid_type_test() {
  io.debug("Testing the monoid type")

  let int_sum_monoid =
    mono.Monoid(mempty: 0, mappend: fn(x: Int, y: Int) { x + y })

  int_sum_monoid.mappend(7, 8)
  |> should.equal(15)

  int_sum_monoid.mappend(4, int_sum_monoid.mempty)
  |> should.equal(4)

  let int_prod_monoid =
    mono.Monoid(mempty: 1, mappend: fn(x: Int, y: Int) { x * y })

  int_prod_monoid
  |> mono.mconcat([2, 3, int_prod_monoid.mempty, 4, int_prod_monoid.mempty])
  |> int_prod_monoid.mappend(10)
  |> should.equal(240)

  let bool_and_monoid = mono.Monoid(mempty: True, mappend: bool.and)

  True
  |> bool_and_monoid.mappend(False)
  |> bool_and_monoid.mappend(bool_and_monoid.mempty)
  |> should.equal(False)
}

pub fn monoid_instances_test() {
  io.debug("Testing the monoid instances")

  let mono_unit = mono.unit_monoid()
  let mono_list = mono.list_monoid()
  let mono_string =
    mono.Monoid(mempty: "", mappend: fn(x: String, y: String) -> String {
      x <> y
    })
  let mono_maybe = mono.option_monoid(mono_string)

  mono_unit.mappend(mono_unit.mempty, Nil)
  |> should.equal(Nil)

  [1, 2]
  |> mono_list.mappend([3, 4, 5])
  |> mono_list.mappend(mono_list.mempty)
  |> mono_list.mappend([6])
  |> should.equal([1, 2, 3, 4, 5, 6])

  option.Some("ab")
  |> mono_maybe.mappend(option.Some("cd"))
  |> should.equal(option.Some("abcd"))

  mono_maybe.mappend(option.Some("abc"), mono_maybe.mempty)
  |> should.equal(option.None)
}
