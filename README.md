# Category Theory

[![Package Version](https://img.shields.io/hexpm/v/cat)](https://hex.pm/packages/cat)
[![Hex Docs](https://img.shields.io/badge/hex-docs-ffaff3)](https://hexdocs.pm/cat)

This package implements several category theory concepts, following [this book](https://bartoszmilewski.com/2014/10/28/category-theory-for-programmers-the-preface/) by Bartosz Milewski.

```sh
gleam add cat
```

Functor Example

```gleam
import cat/functor as fun
import cat/instances/functor as inst
import gleam/option
import gleam/io

pub fn main() {

  option.Some([1, 2, 3])
  |> fun.functor_compose(inst.list_functor(), inst.option_functor())(fn(x) {
    x % 2 == 0
  })
  |> io.debug()
  // -> option.Some([True, False, True])
}
```

Applicative Example

```gleam
import cat/applicative as app
import cat/instances/applicative as inst
import cat/functor as fun
import gleam/option.{None, Some}
import gleam/io

pub fn main() {
  [Some(1), None, Some(3)]
  |> {
    [fn(x) { x * 2 }, fn(x) { x + 10 }]
    |> fun.list_functor().fmap(fun.option_functor().fmap)
    |> app.apply(inst.list_applicative())
  }
  |> io.debug()
  // -> [Some(2), None, Some(6), Some(11), None, Some(13)]
}
```

Monoid Example

```gleam
import cat.{type Either, Left, Right}
import cat/monoid as mono
import gleam/io

pub fn main() {
   let either_sum_monoid =
    mono.Monoid(
      mempty: Left(0),
      mappend: fn(e1: Either(Int, String), e2: Either(Int, String)) -> Either(Int, String) {
        case e1, e2 {
          Right(s), _ -> Right(s)
          _, Right(s) -> Right(s)
          Left(a), Left(b) -> Left(a + b)
        }
      }
    )

  either_sum_monoid
  |> mono.mconcat([Left(2), Left(3), Left(4)])
  |> io.debug()
  // -> Left(9)

  either_sum_monoid
  |> mono.mconcat([Left(2), Right("error"), Left(4)])
  |> io.debug()
  // -> Right("error")
}
```

Bifunctor Example

```gleam
import cat
import cat/bifunctor as bf
import cat/instances/functor as fun
import cat/instances/bifunctor as inst
import gleam/io

pub fn main() {
  // Either bifunctor
  let either_bf = inst.either_bifunctor()
  // Const () functor
  let const_f = fun.const_functor()
  // Identity functor
  let id_f = fun.identity_functor()

  // Constructing the maybe functor:
  // Maybe b = Either (Const () a) (Identity b)
  let maybe_functor = fn() -> bf.Bifunctor(
    bf.BiCompF(bf.EitherBF, fun.ConstF(Nil), fun.IdentityF),
    a, b, c, d,
    cat.Either(cat.Const(Nil, a), cat.Identity(b)),
    cat.Either(cat.Const(Nil, c), cat.Identity(d)),
  ) {
    bf.bifunctor_compose(either_bf, const_f, id_f)
  }

  cat.Left(cat.Const(Nil))
  |> maybe_functor().bimap(fn(_) { panic }, int.to_string)
  |> io.debug()
  // -> cat.Left(cat.Const(Nil))

  cat.Right(cat.Identity(3))
  |> maybe_functor().bimap(fn(_) { panic }, int.to_string)
  |> io.debug()
  // -> cat.Right(cat.Identity("3"))
}
```

Further documentation can be found at <https://hexdocs.pm/cat>.

## Development

```sh
gleam run   # Run the project
gleam test  # Run the tests
```
