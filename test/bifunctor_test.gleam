//// Test module for cat/bifunctor.gleam

import cat
import cat/bifunctor.{
  type BiCompF, type Bifunctor, bifunctor_compose, first, second,
}
import cat/instances/bifunctor as bif
import cat/instances/functor as fun
import gleam/bool
import gleam/int
import gleeunit/should

/// Testing the first function.
pub fn first_test() {
  let first_show =
    int.to_string
    |> {
      bif.pair_bifunctor()
      |> first
    }

  first_show(cat.Pair(8, 9))
  |> should.equal(cat.Pair("8", 9))
}

/// Testing the second function.
pub fn second_test() {
  let second_show = second(bif.either_bifunctor())(int.to_string)

  cat.Left(8)
  |> second_show
  |> should.equal(cat.Left(8))

  cat.Right(9)
  |> second_show
  |> should.equal(cat.Right("9"))
}

/// Testing tuple bifunctor instance.
pub fn tuple_bifunctor_test() {
  #(6, False)
  |> bif.tuple_bifunctor().bimap(fn(x) { [x] }, fn(b) { bool.to_string(b) })()
  |> should.equal(#([6], "False"))
}

/// Testing tuple bifunctor instance.
pub fn pair_bifunctor_test() {
  cat.Pair(2, 3)
  |> bif.pair_bifunctor().bimap(fn(x) { x % 3 }, int.to_string)()
  |> should.equal(cat.Pair(2, "3"))
}

/// Testing either bifunctor instance.
pub fn either_bifunctor_test() {
  let show_or_double =
    bif.either_bifunctor().bimap(int.to_string, fn(x) { x * 2 })

  cat.Left(10)
  |> show_or_double()
  |> should.equal(cat.Left("10"))

  cat.Right(10)
  |> show_or_double()
  |> should.equal(cat.Right(20))
}

/// Testing the compose of a bifunctor with 2 functors.
pub fn bifunctor_compose_test() {
  // Either bifunctor
  let either_bf = bif.either_bifunctor()
  // Const () functor
  let const_f = fun.const_functor()
  // Identity functor
  let id_f = fun.identity_functor()

  // Constructing the maybe functor:
  // Maybe b = Either (Const () a) (Identity b)
  let maybe_functor = fn() -> Bifunctor(
    BiCompF(bif.EitherBF, fun.ConstF(Nil), fun.IdentityF),
    a,
    b,
    c,
    d,
    cat.Either(cat.Const(Nil, a), cat.Identity(b)),
    cat.Either(cat.Const(Nil, c), cat.Identity(d)),
  ) {
    bifunctor_compose(either_bf, const_f, id_f)
  }
  // bimap is equivalent to fmap:
  // fmap :: (b -> d) -> Maybe b -> Maybe d
  // fmap g (Left Const ()) = Left Const ()
  // fmap h (Right Identity y) = Right Identity (h y)
  cat.Left(cat.Const(Nil))
  |> maybe_functor().bimap(fn(_) { panic }, int.to_string)
  |> should.equal(cat.Left(cat.Const(Nil)))

  cat.Right(cat.Identity(3))
  |> maybe_functor().bimap(fn(_) { panic }, int.to_string)
  |> should.equal(cat.Right(cat.Identity("3")))
}
