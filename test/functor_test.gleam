import cat
import cat/functor as fun
import gleam/bool
import gleam/float
import gleam/int
import gleam/list
import gleam/option
import gleeunit/should

/// The type that will be an instance of Functor:
type Identity(a) {
  Identity(a)
}

/// The phantom type that will be the first parameter:
type IdentityF

pub fn functor_test() {
  // Instance of Identity for Functor:
  let identity_functor = fn() -> fun.Functor(
    IdentityF,
    a,
    b,
    Identity(a),
    Identity(b),
  ) {
    fun.Functor(fmap: fn(f) {
      fn(idx) {
        let Identity(x) = idx
        Identity(f(x))
      }
    })
  }

  let f = fn(x: Int) -> Bool { x % 2 == 0 }

  identity_functor().fmap(f)(Identity(5))
  |> should.equal(Identity(False))

  let g = fn(x: Float) -> String { float.to_string(x) }

  identity_functor().fmap(g)(Identity(6.0))
  |> should.equal(Identity("6.0"))
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

/// Testing the reader functor instance.
pub fn reader_functor_test() {
  let f = fn(x) { x % 2 == 0 }
  let g = bool.to_string

  fun.reader_functor().fmap(g)(f)(19)
  |> should.equal("False")
}

/// Testing the const functor instance.
pub fn const_functor_test() {
  fun.const_functor().fmap(int.to_string)(cat.Const(True))
  |> should.equal(cat.Const(True))
}

/// Testing the functor composition.
pub fn functor_compose_test() {
  option.Some([1, 2, 3])
  |> fun.functor_compose(fun.list_functor(), fun.option_functor())(fn(x) {
    int.to_string(x + 1)
  })
  |> should.equal(option.Some(["2", "3", "4"]))
}

pub fn functor_laws() {
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
