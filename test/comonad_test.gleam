import cat.{type Identity, type NonEmpty, Identity, Leaf, Next}
import cat/instances/comonad.{identity_comonad, non_empty_comonad}
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
  Next(1, Next(2, Leaf(3)))
  |> non_empty_comonad().extend(sum)
  |> non_empty_comonad().extract()
  |> should.equal(6)
}
