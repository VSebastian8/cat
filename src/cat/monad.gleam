//// `Monad` type {minimal implementation - `bind`}.

import cat/functor.{type Functor, Functor}

/// `Monad` type.
/// ```
/// class Applicative m => Monad m where
///   (>>=) :: m a -> (a -> m b) -> m b
/// ```
/// This type contains the Functor `map` function which can be calculated by default through the new function.
pub type Monad(m, a, b, ma, mb) {
  Monad(
    return: fn(a) -> ma,
    bind: fn(ma, fn(a) -> mb) -> mb,
    map: fn(ma, fn(a) -> b) -> mb,
  )
}

/// Constructor that provides a default `map` function.
/// ```
/// fmap f mx = bind(mx)(\x -> return(f(x))) 
/// ```
pub fn new(
  return: fn(a) -> ma,
  return2: fn(b) -> mb,
  bind bind: fn(ma, fn(a) -> mb) -> mb,
) -> Monad(m, a, b, ma, mb) {
  Monad(return: return, bind: bind, map: fn(mx, f) {
    bind(mx, fn(x) { return2(f(x)) })
  })
}

/// Functor instance from Monad.
pub fn to_functor(m: Monad(f, a, b, ma, mb)) -> Functor(f, a, b, ma, mb) {
  Functor(fmap: fn(f) { fn(mx) { m.map(mx, f) } })
}
