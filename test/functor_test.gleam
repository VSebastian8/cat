import cat/functor as fun
import gleam/float
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

pub fn option_functor_test() {
  let double = fn(x) { x * 2 }

  option.None
  |> {
    double
    |> fun.option_functor().fmap()
  }
  |> should.equal(option.None)

  option.Some(2)
  |> fun.option_functor().fmap(double)
  |> should.equal(option.Some(4))

  fun.option_fmap(double)(option.Some(7))
  |> should.equal(option.Some(14))
}
