//// `NaturalTransformation` type {minimal implementation `transform`}. \
//// `Composition` function.

import cat.{compose}
import cat/functor.{type Functor, functor_compose}

/// A natural transformation of `two functors` **F** and **G** is a collection of functions such that for every type **a** we have a function (`component`) that goes from **F a** to **G a**.\
/// This implementation in gleam is a bit more restrictive in that each `component` is an instantiation of the `generic` function **transform** for the type **a**.
/// ### Examples
/// A natural transformation from `Option` to `List` will contain a `transform` function that, for any type `a`, takes an `Option(a)` and returns a `List(a)`. 
/// ```gleam
/// transform: fn(Option(a)) -> List(a)
/// ```
pub type NaturalTransformation(f, g, a, b, fa, fb, c, d, gc, gd) {
  NaturalTransformation(
    f: Functor(f, a, b, fa, fb),
    g: Functor(g, c, d, gc, gd),
    transform: fn(fa) -> gc,
  )
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
  alpha: NaturalTransformation(f, g, a, b, fa, fb, c, d, gc, gd),
  beta: NaturalTransformation(g, h, c, d, gc, gd, x, y, hx, hy),
) -> NaturalTransformation(f, h, a, b, fa, fb, x, y, hx, hy) {
  NaturalTransformation(
    f: alpha.f,
    g: beta.g,
    transform: compose(beta.transform, alpha.transform),
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
/// Unfortunately Gleam coerces f1 = f2 because g1 is bound to a type 'f1 a' and is not truly generic 
/// (we need g1 to contain both 'f1 a' and 'f2 a' but the types are bound in the argument list)
pub fn horizontal_composition(
  alpha: NaturalTransformation(f1, f2, _, _, _, _, _, _, _, _),
  beta: NaturalTransformation(g1, g2, _, _, _, _, _, _, _, _),
) {
  NaturalTransformation(
    f: functor_compose(beta.f, alpha.f),
    g: functor_compose(beta.g, alpha.g),
    transform: fn(x) { beta.f.fmap(alpha.transform)(x) |> beta.transform },
  )
}
