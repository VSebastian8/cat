//// `Applicative` type {minimal implementations - `pure` and `apply`}. \
//// Default implementation for `left` (*>), `right` (<*), and `flip_apply` (<**>) operators.

import cat.{id}
import cat/functor.{type Functor, replace}

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

/// Haskell `(<*)` operator.
/// ```
/// (<*) :: f a -> f b -> f a
/// (<*) = liftA2 const
/// ```
pub fn left(_: Applicative(f, a, b, fa, fb, fab)) -> fn(fa, fb) -> fa {
  fn(fa, _) { fa }
}

/// Haskell `(*>)` operator.
/// ```
/// (*>) :: f a -> f b -> f b
/// a1 *> a2 = (id <$ a1) <*> a2
/// ```
/// Unfortunately, you have to pass the instance twice into gleam so that the generic types do not get constrained.
pub fn right(
  ap1: Applicative(f, fa, fn(a) -> a, fa, _, _),
  ap2: Applicative(f, _, _, fb, fb, _),
) -> fn(fa, fb) -> fb {
  fn(a1: fa, a2: fb) {
    let id_f = replace(ap1.f)(id, a1)
    ap2.apply(id_f)(a2)
  }
}

/// Haskell `(<**>)` operator.
/// ```
/// (<**>) :: Applicative f => f a -> f (a -> b) -> f b
/// (<**>) = liftA2 (\a f -> f a)
/// ```
pub fn flip_apply(
  ap: Applicative(f, a, b, fa, fb, fab),
) -> fn(fa) -> fn(fab) -> fb {
  fn(fx) { fn(ff) { ap.apply(ff)(fx) } }
}
