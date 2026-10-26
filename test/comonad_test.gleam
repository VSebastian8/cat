import cat.{type Identity, type NonEmpty, Identity, Leaf, Next}
import cat/instances/comonad.{identity_comonad, non_empty_comonad, tuple_comonad}
import gleam/string
import gleeunit/should

/// Testing the identity comonad instance.
pub fn identity_comonad_test() {
  let double = fn(id: Identity(Int)) -> Int {
    let Identity(x) = id
    x * 2
  }
  Identity(5)
  |> identity_comonad().extend(double)
  |> should.equal(Identity(10))
}

fn sum(vec: NonEmpty(Int)) -> Int {
  case vec {
    Leaf(x) -> x
    Next(x, v) -> x + sum(v)
  }
}

/// Testing the non empty comonad instance.
pub fn non_empty_comonad_test() {
  Next("a", Next("b", Leaf("c")))
  |> non_empty_comonad().duplicate()
  |> should.equal(Next(
    Next("a", Next("b", Leaf("c"))),
    Next(Next("b", Leaf("c")), Leaf(Leaf("c"))),
  ))

  Next(1, Next(2, Next(3, Leaf(4))))
  |> non_empty_comonad().extend(sum)
  |> should.equal(Next(10, Next(9, Next(7, Leaf(4)))))
}

/// Testing the tuple comonad instance.
pub fn tuple_comonad_test() {
  #("hello", 5)
  |> tuple_comonad().extract()
  |> should.equal(5)

  #("hello", 5)
  |> tuple_comonad().duplicate()
  |> should.equal(#("hello", #("hello", 5)))

  #("hello", 5)
  |> tuple_comonad().extend(fn(p: #(String, Int)) { string.length(p.0) == p.1 })
  |> should.equal(#("hello", True))
}
