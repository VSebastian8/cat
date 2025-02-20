//// Test module for cat/functor.gleam

import cat
import cat/functor.{type Functor, Functor, functor_compose, replace}
import cat/instances/functor as fun
import cat/instances/monad
import gleam/bool
import gleam/float
import gleam/int
import gleam/list
import gleam/option
import gleeunit/should

/// The phantom type that will be the first parameter:
type IdentityF

pub fn functor_test() {
  // Instance of Identity for Functor:
  let id_f = fn() -> Functor(IdentityF, a, b, cat.Identity(a), cat.Identity(b)) {
    Functor(fmap: fn(f) {
      fn(idx) {
        let cat.Identity(x) = idx
        cat.Identity(f(x))
      }
    })
  }

  let f = fn(x: Int) -> Bool { x % 2 == 0 }

  id_f().fmap(f)(cat.Identity(5))
  |> should.equal(cat.Identity(False))

  let g = fn(x: Float) -> String { float.to_string(x) }

  id_f().fmap(g)(cat.Identity(6.0))
  |> should.equal(cat.Identity("6.0"))
}

/// Testing the replace function.
pub fn replace_test() {
  replace(fun.option_functor())("a", option.Some(2))
  |> should.equal(option.Some("a"))

  replace(fun.option_functor())("a", option.None)
  |> should.equal(option.None)
}

/// Testing the identity and composition preservation.
pub fn functor_laws_test() {
  list.map(list.range(0, 100), fn(i) {
    fun.option_functor().fmap(cat.id)(option.Some(i))
    |> should.equal(option.Some(i))
  })
  let f = fn(x) { x * 5 }
  let g = fn(x) { x % 2 == 0 }

  list.map(list.range(0, 100), fn(i) {
    let first = fun.option_functor().fmap(cat.compose(g, f))
    let second =
      cat.compose(fun.option_functor().fmap(g), fun.option_functor().fmap(f))
    should.equal(first(option.Some(i)), second(option.Some(i)))
  })
}

/// Testing the option functor instance.
pub fn option_functor_test() {
  let double = fn(x) { x * 2 }

  fun.option_functor().fmap(double)(option.None)
  |> should.equal(option.None)

  option.Some(2)
  |> fun.option_functor().fmap(double)
  |> should.equal(option.Some(4))
}

/// Testing the list functor instance.
pub fn list_functor_test() {
  fun.list_functor().fmap(int.to_string)([1, 3, 4])
  |> should.equal(["1", "3", "4"])
}

/// Testing the const functor instance.
pub fn const_functor_test() {
  fun.const_functor().fmap(int.to_string)(cat.Const(True))
  |> should.equal(cat.Const(True))
}

/// Testing the functor composition.
pub fn functor_compose_test() {
  option.Some([1, 2, 3])
  |> functor_compose(fun.option_functor(), fun.list_functor()).fmap(fn(x) {
    int.to_string(x + 1)
  })
  |> should.equal(option.Some(["2", "3", "4"]))
}

/// Testing the tuple functor instance.
pub fn tuple_functor_test() {
  fun.tuple_functor().fmap(bool.negate)(#(9, False))
  |> should.equal(#(9, True))
}

/// Testing the triple functor instance.
pub fn triple_functor_test() {
  fun.triple_functor().fmap(bool.negate)(#("abc", 9, False))
  |> should.equal(#("abc", 9, True))
}

/// Testing the pair functor instance.
pub fn pair_functor_test() {
  fun.pair_functor().fmap(bool.negate)(cat.Pair(9, False))
  |> should.equal(cat.Pair(9, True))
}

/// Testing the either functor instance.
pub fn either_functor_test() {
  fun.either_functor().fmap(bool.negate)(cat.Left(27))
  |> should.equal(cat.Left(27))

  fun.either_functor().fmap(bool.negate)(cat.Right(False))
  |> should.equal(cat.Right(True))
}

/// Testing the function (reader) functor instance.
pub fn function_functor_test() {
  let g = fn(x) { x % 2 == 0 }
  let f = bool.to_string

  fun.function_functor().fmap(f)(g)(19)
  |> should.equal("False")
}

/// Testing the reader functor instance.
pub fn reader_functor_test() {
  let ra = monad.Reader(fn(x) { x % 2 == 0 })
  let f = bool.to_string

  fun.reader_functor().fmap(f)(ra).apply(19)
  |> should.equal("False")
}

/// Testing the writer functor instance.
pub fn writer_functor_test() {
  monad.Writer(16, "message")
  |> fun.writer_functor().fmap(fn(x) { x % 4 == 0 })
  |> should.equal(monad.Writer(True, "message"))
}
