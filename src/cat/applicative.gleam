//// `Applicative` type {minimal implementations - `pure` and `apply`}. \
//// Default implementation for `left` (*>), `right` (<*), and `flip_apply` (<**>) operators.

import cat.{constant, id}
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
/// Unfortunately, you have to pass the instance twice into gleam so that the generic types do not get constrained.
/// ### Examples
/// ```gleam
/// let ap_left = left(option_applicative(), option_applicative())
///
/// ap_left(Some(2), Some(3))
/// // -> Some(2)
/// ap_left(None, Some(3))
/// // -> None
/// ap_left(Some(2), None)
/// // -> None
///```
pub fn left(
  ap1: Applicative(f, _, _, _, _, _),
  ap2: Applicative(f, _, _, _, _, _),
) -> fn(fa, fb) -> fa {
  fn(a1: fa, a2: fb) {
    let const_f = ap1.f.fmap(constant)(a1)
    ap2.apply(const_f)(a2)
  }
}

/// Haskell `(*>)` operator.
/// ```
/// (*>) :: f a -> f b -> f b
/// a1 *> a2 = (id <$ a1) <*> a2
/// ```
/// Unfortunately, you have to pass the instance twice into gleam so that the generic types do not get constrained.
/// ### Examples
/// ```gleam
/// let ap_right = right(option_applicative(), option_applicative())
///
/// ap_right(Some(2), Some(3))
/// // -> Some(3)
/// ap_right(None, Some(3))
/// // -> None
/// ap_right(Some(2), None)
/// // -> None
///```
pub fn right(
  ap1: Applicative(f, _, _, _, _, _),
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
/// ### Examples
/// ```gleam
/// let identity_f =
///   fn(x: Int, y: String) { int.to_string(x) <> y }
///   |> curry()
///   |> identity_applicative().pure()
///
/// flip_apply(identity_applicative())(Identity(" apples"))(
///   flip_apply(identity_applicative())(Identity(6))(
///     identity_f,
///   ),
/// )
/// // -> Identity("6 apples")
/// ```
pub fn flip_apply(
  ap: Applicative(f, a, b, fa, fb, fab),
) -> fn(fa) -> fn(fab) -> fb {
  fn(fx) { fn(ff) { ap.apply(ff)(fx) } }
}
