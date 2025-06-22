//// `Monad` type {minimal implementation - `bind`}.

import cat/applicative.{type Applicative}

/// `Monad` type.
/// ```
/// class Applicative m => Monad m where
///   (>>=) :: m a -> (a -> m b) -> m b
/// ```
/// The gleam type needs to contain the `Functor` instance in order to have access to `pure`, `apply`, and `fmap`.
pub type Monad(m, a, b, ma, mb, mab) {
  Monad(
    ap: Applicative(m, a, b, ma, mb, mab),
    return: fn(a) -> ma,
    bind: fn(ma) -> fn(fn(a) -> mb) -> mb,
  )
}
