//// `Applicative` type {minimal implementations - `pure` and `apply`}.

import cat/functor.{type Functor}

/// `Applicative` type.
/// ```
/// class Functor f => Applicative f where
///     pure :: a -> f a
///     (<*>) :: f (a -> b) -> f a -> f b
/// ```
/// The gleam type needs to contain the `Functor` instance in order to have access to `fmap`.
pub type Applicative(f, a, b, fa, fb, fab) {
  Applicative(
    f: Functor(f, a, b, fa, fb),
    pure: fn(a) -> fa,
    apply: fn(fab) -> fn(fa) -> fb,
  )
}
