import cat/instances/monad.{list_monad as lsm, option_monad as opt}
import gleam/int
import gleam/option.{None, Some}
import gleeunit/should

pub fn opt_test() -> Nil {
  let sum = {
    use x <- opt().bind(Some(1))
    use y <- opt().bind(Some(2))
    use z <- opt().map(Some(3))
    x + y + z
  }
  let none = {
    use x <- opt().bind(Some(1))
    use y <- opt().bind(None)
    use z <- opt().map(Some(3))
    x + y + z
  }
  sum
  |> should.equal(Some(6))
  none
  |> should.equal(None)
}

pub fn lsm_test() -> Nil {
  let grocery_list = {
    use quantity <- lsm().bind([2, 3, 4])
    use fruit <- lsm().map(["apples", "oranges"])
    int.to_string(quantity * 10) <> " " <> fruit
  }
  grocery_list
  |> should.equal([
    "20 apples", "20 oranges", "30 apples", "30 oranges", "40 apples",
    "40 oranges",
  ])
}

import cat/functor as fun
import cat/instances/applicative.{list_applicative}
import cat/instances/functor.{
  const_functor, identity_functor, list_functor, option_functor,
}

pub fn func_app_test() -> Nil {
  Some([1, 2, 3])
  |> fun.functor_compose(option_functor(), list_functor()).fmap(fn(x) {
    x % 2 != 0
  })
  |> should.equal(Some([True, False, True]))

  [Some(1), None, Some(3)]
  |> {
    [fn(x) { x * 2 }, fn(x) { x + 10 }]
    |> list_functor().fmap(option_functor().fmap)
    |> list_applicative().apply
  }
  |> should.equal([Some(2), None, Some(6), Some(11), None, Some(13)])
}

import cat.{type Either, Left, Right}
import cat/monoid as mono

pub fn mono_test() -> Nil {
  let either_sum_monoid =
    mono.Monoid(
      mempty: Left(0),
      mappend: fn(e1: Either(Int, String), e2: Either(Int, String)) -> Either(
        Int,
        String,
      ) {
        case e1, e2 {
          Right(s), _ -> Right(s)
          _, Right(s) -> Right(s)
          Left(a), Left(b) -> Left(a + b)
        }
      },
    )

  either_sum_monoid
  |> mono.mconcat([Left(2), Left(3), Left(4)])
  |> should.equal(Left(9))

  either_sum_monoid
  |> mono.mconcat([Left(2), Right("error"), Left(4)])
  |> should.equal(Right("error"))
}

import cat/bifunctor as bf
import cat/instances/bifunctor.{either_bifunctor}
import cat/instances/types.{
  type BiCompF, type ConstF, type EitherBF, type IdentityF,
}

pub fn bif_test() {
  // Either bifunctor
  let either_bf = either_bifunctor()
  // Const () functor
  let const_f = const_functor()
  // Identity functor
  let id_f = identity_functor()
  // Constructing the maybe functor:
  // Maybe b = Either (Const () a) (Identity b)
  let maybe_functor = fn() -> bf.Bifunctor(
    BiCompF(EitherBF, ConstF(Nil), IdentityF),
    a,
    b,
    c,
    d,
    cat.Either(cat.Const(Nil, a), cat.Identity(b)),
    cat.Either(cat.Const(Nil, c), cat.Identity(d)),
  ) {
    bf.bifunctor_compose(either_bf, const_f, id_f)
  }

  cat.Left(cat.Const(Nil))
  |> maybe_functor().bimap(fn(_) { panic }, int.to_string)
  |> should.equal(cat.Left(cat.Const(Nil)))

  cat.Right(cat.Identity(3))
  |> maybe_functor().bimap(fn(_) { panic }, int.to_string)
  |> should.equal(cat.Right(cat.Identity("3")))
}
