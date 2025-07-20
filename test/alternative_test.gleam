import cat/instances/alternative.{
  list_alternative, option_alternative, result_alternative,
}
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
