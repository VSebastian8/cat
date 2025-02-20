//// `NaturalTransformation` type {minimal implementation `transform`}. \
//// `Composition` function.

import cat
import cat/functor.{type Functor}

/// A natural transformation of `two functors` **F** and **G** is a collection of functions such that for every type **a** we have a function (`component`) that goes from **F a** to **G a**.\
/// This implementation in gleam is a bit more restrictive in that each `component` is an instantiation of the `generic` function **transform** for the type **a**.
/// ### Examples
/// A natural transformation from `Option` to `List` will contain a `transform` function that, for any type `a`, takes an `Option(a)` and returns a `List(a)`. 
/// ```gleam
/// transform: fn(Option(a)) -> List(a)
/// ```
pub opaque type NaturalTransformation(f, g, fa, ga) {
  NaturalTransformation(f: fn() -> f, g: fn() -> g, transform: fn(fa) -> ga)
}

/// `Smart constructor` for the `NaturalTransformation` type. \
/// Takes two functor instance generation (so that the types stay generic) and a transform function.
pub fn new(
  f: fn() -> Functor(f, a, b, fa, fb),
  g: fn() -> Functor(g, c, d, gc, gd),
  transform,
) -> NaturalTransformation(
  Functor(f, a, b, fa, fb),
  Functor(g, c, d, gc, gd),
  fa,
  ga,
) {
  NaturalTransformation(f: f, g: g, transform: transform)
}

/// Getter for the `transform` field of `NaturalTransformation`.
pub fn transform(alpha: NaturalTransformation(_, _, fa, ga)) -> fn(fa) -> ga {
  alpha.transform
}

/// Getter for the `fmap` of `f` of `NaturalTransformation`.
pub fn ffmap(
  alpha: NaturalTransformation(Functor(f, a, b, fa, fb), _, _, _),
) -> fn(fn(a) -> b) -> fn(fa) -> fb {
  alpha.f().fmap
}

/// Getter for the `fmap` of `g` of `NaturalTransformation`.
pub fn gfmap(
  alpha: NaturalTransformation(_, Functor(g, a, b, ga, gb), _, _),
) -> fn(fn(a) -> b) -> fn(ga) -> gb {
  alpha.g().fmap
}

/// `Vertical composition` ⋅ of two `natural transformations`.
/// ```
/// alpha_a :: F a -> G a
/// beta_a :: G a -> H a
/// // These morphisms compose:
/// beta_a ∘ alpha_a :: F a -> H a
/// // So the natural transformations also compose:
/// (beta ⋅ alpha)_a = beta_a ∘ alpha_a
/// ```
/// ### Examples
/// ```gleam
/// let maybe_const = 
///   vertical_composition(
///     option_list_transformation(),
///     list_length_transformation()
///   )
/// None
/// |> transform(maybe_const)
/// // -> Const(0)
/// Some("abc")
/// |> transform(maybe_const)
/// // -> Const(1)
/// ```
pub fn vertical_composition(
  alpha: NaturalTransformation(f, g, fa, ga),
  beta: NaturalTransformation(g, h, ga, ha),
) -> NaturalTransformation(f, h, fa, ha) {
  NaturalTransformation(
    f: alpha.f,
    g: beta.g,
    transform: cat.compose(beta.transform, alpha.transform),
  )
}

/// `Horizontal composition` ∘ of two `natural transformations`.
/// ```
/// alpha_a :: F a -> F' a
/// beta_a :: G a -> G' a
/// // These transformation compose:
/// beta ∘ alpha :: G ∘ F -> G' ∘ F'
/// (beta ∘ alpha)_a = G' (alpha_a) ∘ beta_Fa = beta_F'a ∘ G (alpha_a)
/// ```
/// Due to gleam's type system, we cannot implement this generic function
@deprecated("Imposible to implement")
pub fn horizontal_composition(
  _alpha: NaturalTransformation(
    Functor(f1, a, b, f1a, f1b),
    Functor(f2, a, b, f2a, f2b),
    f1a,
    f2a,
  ),
  _beta: NaturalTransformation(
    Functor(g1, fa, fb, g1fa, g1fb),
    Functor(g2, fa, fb, g2fa, g2fb),
    g1fa,
    g2fa,
  ),
) -> NaturalTransformation(
  Functor(cat.Pair(f1, g1), a, b, g1f1a, g1f1b),
  Functor(cat.Pair(f2, g2), a, b, g2f2a, g2f2b),
  g1f1a,
  g2f2b,
) {
  // let f1g1 = functor_compose(beta.f(), alpha.f())
  // let f2g2 = functor_compose(beta.g(), alpha.g())
  panic
}
