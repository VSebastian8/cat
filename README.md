# Category Theory

[![Package Version](https://img.shields.io/hexpm/v/cat)](https://hex.pm/packages/cat)
[![Hex Docs](https://img.shields.io/badge/hex-docs-ffaff3)](https://hexdocs.pm/cat)

This package implements several category theory concepts, following [this book](https://bartoszmilewski.com/2014/10/28/category-theory-for-programmers-the-preface/) by Bartosz Milewski.

```sh
gleam add cat
```

Monoid Example

```gleam
import cat.{type Either, Left, Right}
import cat/monoid as mono


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
  |> io.debug
  // -> Left(9)

  either_sum_monoid
  |> mono.mconcat([Left(2), Right("error"), Left(4)])
  |> io.debug
  // -> Right("error")
}
```

Functor Example

```gleam
import cat/functor as fun
import gleam/option

pub fn main() {

  option.Some([1, 2, 3])
  |> fun.functor_compose(fun.list_functor(), fun.option_functor())(fn(x) {
    x % 2 == 0
  })
  |> io.debug
  // -> option.Some([True, False, True])
}
```

Bifunctor Example

```gleam
import cat
import cat/functor as fun
import cat/bifunctor as bf
import gleam/option

pub fn main() {
  // Either bifunctor
  let either_bf = bif.either_bifunctor()
  // Const () functor
  let const_f = fun.const_functor()
  // Identity functor
  let id_f = fun.identity_functor()

  // Constructing the maybe functor:
  // Maybe b = Either (Const () a) (Idenity b)
  let maybe_functor = fn() -> bif.Bifunctor(
    bif.BiCompF(bif.EitherBF, fun.ConstF(Nil), fun.IdentityF),
    a, b, c, d,
    cat.Either(cat.Const(Nil, a), cat.Identity(b)),
    cat.Either(cat.Const(Nil, c), cat.Identity(d)),
  ) {
    bif.bifunctor_compose(either_bf, const_f, id_f)
  }

  cat.Left(cat.Const(Nil))
  |> maybe_functor().bimap(fn(_) { panic }, int.to_string)
  |> io.debug
  // -> cat.Left(cat.Const(Nil))

  cat.Right(cat.Identity(3))
  |> maybe_functor().bimap(fn(_) { panic }, int.to_string)
  |> io.debug
  // -> should.equal(cat.Right(cat.Identity("3")))
}
```

Further documentation can be found at <https://hexdocs.pm/cat>.

## Development

```sh
gleam run   # Run the project
gleam test  # Run the tests
```
