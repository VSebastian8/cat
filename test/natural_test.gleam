import cat.{Const}
import cat/natural as nat
import gleam/option
import gleeunit/should

/// Testing natural transformation examples.
pub fn natural_transformations_test() {
  option.None
  |> { nat.option_list_transformation() |> nat.transform() }
  |> should.equal([])

  option.Some(7)
  |> nat.transform(nat.option_list_transformation())
  |> should.equal([7])

  []
  |> { nat.list_option_head_transformation() |> nat.transform() }
  |> should.equal(option.None)

  [1, 2, 3]
  |> { nat.list_option_head_transformation() |> nat.transform() }
  |> should.equal(option.Some(1))

  []
  |> { nat.list_length_transformation() |> nat.transform() }
  |> should.equal(Const(0))

  [1, 2, 3, 4]
  |> { nat.list_length_transformation() |> nat.transform() }
  |> should.equal(Const(4))
}

/// Testing the composition function.
pub fn vertical_composition_test() {
  let maybe_const =
    nat.vertical_composition(
      nat.option_list_transformation(),
      nat.list_length_transformation(),
    )

  option.None
  |> nat.transform(maybe_const)
  |> should.equal(Const(0))

  option.Some("abc")
  |> nat.transform(maybe_const)
  |> should.equal(Const(1))
}
