//// `Monad` type {minimal implementation - `bind`}.

import cat/functor.{type Functor, Functor}

/// `Monad` type.
/// ```
/// class Applicative m => Monad m where
///   (>>=) :: m a -> (a -> m b) -> m b
/// ```
/// This type contains the Functor `map` function which can be calculated by default through the new function.
/// Just like Haskell's `do notation`, Gleam has `use expressions` that act as syntactic sugar:
/// ```
/// // Haskell
/// sum :: Maybe Int
/// sum = do
///   x <- Just 1
///   y <- Just 2 
///   return x + y
/// ``` 
/// ```gleam
/// 
/// // Gleam
/// fn sum() -> Option(Int) {
///   use x <- option_monad().bind(Some(1))
///   use y <- option_monad().bind(Some(2))
///   option_monad().return(x + y)
/// }
/// ```
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
