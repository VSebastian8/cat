# category_theory

[![Package Version](https://img.shields.io/hexpm/v/category_theory)](https://hex.pm/packages/category_theory)
[![Hex Docs](https://img.shields.io/badge/hex-docs-ffaff3)](https://hexdocs.pm/category_theory/)

This package implements several category theory concepts, following [this book](https://bartoszmilewski.com/2014/10/28/category-theory-for-programmers-the-preface/) by Bartosz Milewski.

```sh
gleam add category_theory@1
```

```gleam
import category_theory.{Either, Left, Right}
import category_theory/monoid as mono

pub fn main() {
   let either_sum_monoid =
    mono.Monoid(mempty: Left(0), mappend: fn(e1: Either(Int, String), e2: Either(Int, String)) -> Either(Int, String) {
      case e1, e2 {
        Right(s), _ -> Right(s)
        _, Right(s) -> Right(s)
        Left(a), Left(b) -> Left(a + b)
      }
    })

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

Further documentation can be found at <https://hexdocs.pm/category_theory>.

## Development

```sh
gleam run   # Run the project
gleam test  # Run the tests
```
