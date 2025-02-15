# Category Theory

[![Package Version](https://img.shields.io/hexpm/v/cat)](https://hex.pm/packages/cat)
[![Hex Docs](https://img.shields.io/badge/hex-docs-ffaff3)](https://hexdocs.pm/cat)

This package implements several category theory concepts, following [this book](https://bartoszmilewski.com/2014/10/28/category-theory-for-programmers-the-preface/) by Bartosz Milewski.

```sh
gleam add cat
```

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
  |> io.debug()
  // -> Left(9)

  either_sum_monoid
  |> mono.mconcat([Left(2), Right("error"), Left(4)])
  |> io.debug()
  // -> Right("error")
}
```

Further documentation can be found at <https://hexdocs.pm/cat>.

## Development

```sh
gleam run   # Run the project
gleam test  # Run the tests
```
