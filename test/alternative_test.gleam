import cat/alternative as alt
import cat/instances/alternative.{
  list_alternative, monoid_functor_alternative, option_alternative,
  result_alternative,
}
import cat/instances/functor.{list_functor}
import cat/instances/monoid.{list_monoid}
import gleam/option.{None, Some}
import gleeunit/should

// Testing the option alternative instance.
pub fn option_alternative_test() {
  option_alternative().or(Some(2), Some(3))
  |> should.equal(Some(2))
  option_alternative().or(Some(2), None)
  |> should.equal(Some(2))
  option_alternative().or(None, Some(3))
  |> should.equal(Some(3))
  option_alternative().or(None, None)
  |> should.equal(None)
}

// Testing the list alternative instance.
pub fn list_alternative_test() {
  list_alternative().or([1, 2, 3], [4, 5, 6])
  |> should.equal([1, 2, 3])
  list_alternative().or([1, 2, 3], [])
  |> should.equal([1, 2, 3])
  list_alternative().or([], [4, 5, 6])
  |> should.equal([4, 5, 6])
  list_alternative().or([], [])
  |> should.equal([])
}

// Testing the result alternative instance.
pub fn result_alternative_test() {
  result_alternative("").or(Ok(2), Ok(3))
  |> should.equal(Ok(2))
  result_alternative("").or(Ok(2), Error("Nan"))
  |> should.equal(Ok(2))
  result_alternative("").or(Error("Nan"), Ok(3))
  |> should.equal(Ok(3))
  result_alternative("err").or(Error("Nan"), Error("Nan"))
  |> should.equal(Error("Nan"))
}

// Testing the monoid instances.
pub fn monoid_alternative_test() {
  let inst = monoid_functor_alternative(list_monoid(), list_functor())
  inst.or(inst.empty, [1, 2, 3])
  |> should.equal([1, 2, 3])
  inst.or([1, 2], [3, 4, 5])
  |> should.equal([1, 2, 3, 4, 5])
}

// Testing the fold function.
pub fn fold_test() {
  alt.fold(option_alternative(), [None, None, Some(2), Some(3), None])
  |> should.equal(Some(2))
  alt.fold(option_alternative(), [None, None, None])
  |> should.equal(None)
  alt.fold(option_alternative(), [])
  |> should.equal(None)
}
