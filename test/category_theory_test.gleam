import category_theory as ct
import gleam/bool
import gleam/int
import gleam/io
import gleam/list
import gleam/option
import gleam/string
import gleeunit
import gleeunit/should
import instances as inst

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

pub fn identity_test() {
  io.debug("Testing the identity function")
  ct.id(2)
  |> should.equal(2)

  ct.id("abc")
  |> should.equal("abc")

  ct.id(True)
  |> should.equal(True)
}

pub fn composition_test() {
  io.debug("Testing the composition function")

  let y = fn(x: Int) { int.to_string(x) }
  let z = fn(s: String) { s == "28" }
  let h = ct.compose(z, y)

  h(28)
  |> should.equal(True)

  h(29)
  |> should.equal(False)
}

pub fn composition_rules_test() {
  io.debug("Testing the composition rules")

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

pub fn unit_function_test() {
  io.println("Testing unit function")

  ct.unit(5)
  |> should.equal(Nil)

  ct.unit("abc")
  |> should.equal(Nil)
}

pub fn monoid_type_test() {
  io.debug("Testing the monoid type")

  let int_sum_monoid =
    ct.Monoid(mempty: 0, mappend: fn(x: Int, y: Int) { x + y })

  int_sum_monoid.mappend(7, 8)
  |> should.equal(15)

  int_sum_monoid.mappend(4, int_sum_monoid.mempty)
  |> should.equal(4)

  let int_prod_monoid =
    ct.Monoid(mempty: 1, mappend: fn(x: Int, y: Int) { x * y })

  int_prod_monoid
  |> ct.mconcat([2, 3, int_prod_monoid.mempty, 4, int_prod_monoid.mempty])
  |> int_prod_monoid.mappend(10)
  |> should.equal(240)

  let bool_and_monoid = ct.Monoid(mempty: True, mappend: bool.and)

  True
  |> bool_and_monoid.mappend(False)
  |> bool_and_monoid.mappend(bool_and_monoid.mempty)
  |> should.equal(False)
}

pub fn monoid_instances_test() {
  io.debug("Testing the monoid instances")

  let mono_unit = inst.unit_monoid()
  let mono_list = inst.list_monoid()
  let mono_string =
    ct.Monoid(mempty: "", mappend: fn(x: String, y: String) -> String { x <> y })
  let mono_maybe = inst.option_monoid(mono_string)

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

pub fn writer_test() {
  io.debug("Testing the writer type")

  let up_case = fn(s: String) { ct.Writer(string.uppercase(s), "upCase ") }
  let to_words = fn(s: String) { ct.Writer(string.split(s, " "), "toWords ") }
  let process = ct.fish(up_case, to_words)

  process("Anna has apples")
  |> should.equal(ct.Writer(["ANNA", "HAS", "APPLES"], "upCase toWords "))

  ct.return(27)
  |> should.equal(ct.Writer(27, ""))
}
