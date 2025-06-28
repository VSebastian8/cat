# Category Theory

[![Package Version](https://img.shields.io/hexpm/v/cat)](https://hex.pm/packages/cat)
[![Hex Docs](https://img.shields.io/badge/hex-docs-ffaff3)](https://hexdocs.pm/cat)

`Use expressions` are Gleam's flavour of Haskell's `do notation` or Scala's `for comprehensions`. Cat's main feature is the `Monad` type that can be used with use expressions to create clean chains of code.
The rest of the package implements several `category theory` concepts, following [this book](https://bartoszmilewski.com/2014/10/28/category-theory-for-programmers-the-preface/) by _Bartosz Milewski_. These concepts prove extremely useful in understanding `generic programming`, a concept handled very neatly in Gleam.

```sh
gleam add cat
```

### Monad examples

```gleam
import cat/instances/monad.{option_monad as opt}
import gleam/option.{None, Some}

pub fn main() -> Nil {
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
  echo sum
  // -> Some(6)
  echo none
  // -> None
  Nil
}
```

```gleam
import cat/instances/monad.{list_monad as lsm}
import gleam/int
import gleam/option.{None, Some}

pub fn main() -> Nil {
  let grocery_list = {
    use quantity <- lsm().bind([2, 3, 4])
    use fruit <- lsm().map(["apples", "oranges"])
    int.to_string(quantity * 10) <> " " <> fruit
  }
  echo grocery_list
  // -> ["20 apples", "20 oranges", "30 apples", "30 oranges", "40 apples", "40 oranges"]
  Nil
}
```

### A note on generic programming in Gleam

Gleam is designed to avoid unnecessary complexity. While this is a great design choice, the lack of type classes and other expressive features raises some issues when trying to design a library with moderate to high abstractions. This package can also be considered an experiment in pushing Gleam's `simple type system` to the limit.

Let's take a real example from this package, the `Functor` type, and see what problems we run into by trying to define it. At it's most basic, a Functor instance consists of an implementation for the fmap function: `fmap :: (a -> b) -> f a -> f b`. We would like to define a sort of template that the user can later instantiate for specific types, such as List: `fmap :: (a -> b) -> List(a) -> List(b)`.

The first limitation is Gleam's lack of `ad hoc polymorphism`, as it does not support function overloading or type classes. That means the user would need to define separate fmap functions for each instantiation: `list_fmap`, `option_fmap`, `result_fmap` etc. While this results in readable code, it simply shortcircuits the generic aspect of the functor interface. The solution to this problem is wrapping fmap in a custom type, resulting in: `list_functor.fmap`, `option_functor.fmap` etc.

The next problem is that Gleam does not yet support `Higher-Kinded Types`. We would ideally want to write the functor type like this:

```gleam
pub type Functor(f) { Functor(fmap: fn(fn(a) -> b) -> fn(f(a)) -> f(b)) }
```

However, this is not valid Gleam code as f is a simple type, not a type constructor. Compromise: we can rename `f(a)` and `f(b)` as the simple types `fa` and `fb` with the convention that they are types constructed by the Functor, such as `Option(a)` and `Option(b)`. Now, it falls on the user to keep this convention as the gleam compiler doesn't know the relationship between `a` and `fa`.

The third, and bigest, limitation is that gleam doesn't allow `free generics` inside custom types. That means that the following code still doesn't compile:

```gleam
pub type Functor(f) { Functor(fmap: fn(fn(a) -> b) -> fn(fa) -> fb) }
```

Since the compiler does not recognize the generic types `a`, `b`, `fa`, and `fb`, they need to be passsed in like so:

```gleam
pub type Functor(f, a, b, fa, fb) { Functor(fmap: fn(fn(a) -> b) -> fn(fa) -> fb) }
```

This final code snippet does compile and is the actual way the Functor type is implemented in `cat`. There is one big issue that arises from this implementation. Say we want to use the option_functor twice with the functions `f :: fn(Int) -> String` and `g :: fn(Int) -> Bool`, we cannot use the same option_functor as each instance requires the bound types `a` and `b` to be Int and String/Bool. So the types are not truly generic for the functor instance of `Option`. Even if we define the option_functor as `Functor(f, a, b, Option(a), Option(b))`, the concrete types get inferred at compile time. Therefore, we need to call `option_functor()`twice to get two separate instances: `Functor(f, Int, String, Option(Int), Option(String))` and `Functor(f, Int, Bool, Option(Int), Option(Bool))`.

Finally, we choose to keep passing in the unused type `f` as to soleadify the `fa` and `fb` convention. This will be a `phantom type` like `pub type OptionF` that will then be used to return a yet-to-be-bound generic option functor: `fn option_functor() -> Functor(OptionF, a, b, Option(a), Option(b)) { ... }`.

### Other CT examples

Functor & Applicative example

```gleam
import cat/functor as fun
import cat/instances/applicative.{list_applicative}
import cat/instances/functor.{list_functor, option_functor}
import gleam/option.{None, Some}

pub fn main() -> Nil {
  echo Some([1, 2, 3])
    |> fun.functor_compose(option_functor(), list_functor()).fmap(fn(x) {
      x % 2 != 0
    })
  // -> Some([True, False, True])
  echo [Some(1), None, Some(3)]
    |> {
      [fn(x) { x * 2 }, fn(x) { x + 10 }]
      |> list_functor().fmap(option_functor().fmap)
      |> list_applicative().apply
    }
  // -> [Some(2), None, Some(6), Some(11), None, Some(13)]
  Nil
}
```

Monoid Example

```gleam
import cat.{type Either, Left, Right}
import cat/monoid as mono

pub fn main() -> Nil {
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
  echo either_sum_monoid
    |> mono.mconcat([Left(2), Left(3), Left(4)])
  // -> Left(9)
  echo either_sum_monoid
    |> mono.mconcat([Left(2), Right("error"), Left(4)])
  // -> Right("error")
  Nil
}
```

Bifunctor Example

```gleam
import cat
import cat/bifunctor as bf
import cat/instances/bifunctor.{either_bifunctor}
import cat/instances/functor.{const_functor, identity_functor}
import cat/instances/types.{
  type BiCompF, type ConstF, type EitherBF, type IdentityF,
}
import gleam/int

pub fn main() {
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
  echo cat.Left(cat.Const(Nil))
    |> maybe_functor().bimap(fn(_) { panic }, int.to_string)
  // -> cat.Left(cat.Const(Nil))
  echo cat.Right(cat.Identity(3))
    |> maybe_functor().bimap(fn(_) { panic }, int.to_string)
  // -> cat.Right(cat.Identity("3"))
  Nil
}
```

Further documentation can be found at <https://hexdocs.pm/cat>.
