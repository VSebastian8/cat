//// `Monad` type {minimal implementation - `bind`}.

import cat/applicative as app
import cat/functor as fun

/// `Monad` type.
/// ```
/// class Applicative f => Monad f where
///   (>>=) :: m a -> (a -> m b) -> m b
/// ```
pub opaque type Monad(ap, a, ma, mb) {
  Monad(
    ap: fn() -> ap,
    return: fn(a) -> ma,
    bind: fn(ma) -> fn(fn(a) -> mb) -> mb,
  )
}

/// Smart constructor for `Monad` type.
pub fn new(
  ap: fn() -> app.Applicative(fun.Functor(f, a, b, fa, fb), a, fab, fa, fb),
  return: fn(a) -> ma,
  bind: fn(ma) -> fn(fn(a) -> mb) -> mb,
) -> Monad(
  app.Applicative(fun.Functor(f, a, b, fa, fb), a, fab, fa, fb),
  a,
  ma,
  mb,
) {
  Monad(ap: ap, return: return, bind: bind)
}

/// Getter for Monad `fmap`.
pub fn fmap(
  m: Monad(
    app.Applicative(fun.Functor(f, a, b, fa, fb), a, fab, fa, fb),
    a,
    ma,
    mb,
  ),
) {
  m.ap() |> app.fmap()
}

/// Getter for Monad `pure`.
pub fn pure(
  m: Monad(
    app.Applicative(fun.Functor(f, a, b, fa, fb), a, fab, fa, fb),
    a,
    ma,
    mb,
  ),
) {
  m.ap() |> app.pure()
}

/// Getter for Monad `apply`.
pub fn apply(
  m: Monad(
    app.Applicative(fun.Functor(f, a, b, fa, fb), a, fab, fa, fb),
    a,
    ma,
    mb,
  ),
) {
  m.ap() |> app.apply()
}

/// Getter for Monad `return`.
pub fn return(
  m: Monad(
    app.Applicative(fun.Functor(f, a, b, fa, fb), a, fab, fa, fb),
    a,
    ma,
    mb,
  ),
) {
  m.return
}

/// Getter for Monad `bind`.
pub fn bind(
  m: Monad(
    app.Applicative(fun.Functor(f, a, b, fa, fb), a, fab, fa, fb),
    a,
    ma,
    mb,
  ),
) {
  m.bind
}
