//// `Applicative` type {minimal implementations - `pure` and `apply`}.

import cat/functor.{type Functor, Functor}

/// `Applicative` type.
/// ```
/// class Functor f => Applicative f where
///     pure :: a -> f a
///     (<*>) :: f (a -> b) -> f a -> f b
/// ```
pub opaque type Applicative(f, a, fab, fa, fb) {
  Applicative(f: fn() -> f, pure: fn(a) -> fa, apply: fn(fab) -> fn(fa) -> fb)
}

/// `Smart constructor` for the `Applicative` type.
pub fn new(
  f: fn() -> Functor(f, a, b, fa, fb),
  pure: fn(a) -> fa,
  apply: fn(fab) -> fn(fa) -> fb,
) -> Applicative(Functor(f, a, b, fa, fb), a, fab, fa, fb) {
  Applicative(f: f, pure: pure, apply: apply)
}

/// Getter for Applicative `fmap`.
pub fn fmap(
  applicative: Applicative(Functor(f, a, b, fa, fb), a, fab, fa, fb),
) -> fn(fn(a) -> b) -> fn(fa) -> fb {
  applicative.f().fmap
}

/// Getter for Applicative `pure`.
pub fn pure(
  applicative: Applicative(Functor(f, a, b, fa, fb), a, fab, fa, fb),
) -> fn(a) -> fa {
  applicative.pure
}

/// Getter for Applicative `apply`.
pub fn apply(
  applicative: Applicative(Functor(f, a, b, fa, fb), a, fab, fa, fb),
) -> fn(fab) -> fn(fa) -> fb {
  applicative.apply
}
