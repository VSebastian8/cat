//// `Contravariant` functor type {minimal implementation - `contramap`}. \
//// Default implementations for: `replace`, `replace_flip` (>$ and $< operators), and `phantom` function.

import cat
import cat/functor as fun

/// `Contravariant` type in gleam.
/// ```
/// // Haskell type class
/// class Contravariant f where
///     contramap :: (a -> b) -> f b -> f a
/// ```
/// ### Contravariant laws:
/// - Preservation of `identity`: **contramap id = id**
/// - Preservation of `composition`: **contramap (g ∘ h) = (contramap h) ∘ (contramap g)** 
/// 
/// See [`functor type`](#Functor) for convention.
pub type Contravariant(f, a, b, fa, fb) {
  Contravariant(contramap: fn(fn(a) -> b) -> fn(fb) -> fa)
}

/// Haskell `(>$)` operator.
/// ```
/// (>$) :: b -> f b -> f a
/// (>$) = contramap ∘ const
/// ```
/// ### Examples
/// ```gleam
/// let o = con.Op(int.to_string)
/// // Doesn't matter what value/type we send to the final apply  
/// True
/// |> replace(op_contravariant())(7, o).apply
/// // -> "7"
/// ```
pub fn replace(contravar: Contravariant(_, a, b, fa, fb)) -> fn(b, fb) -> fa {
  fn(x: b, m: fb) { contravar.contramap(cat.constant(x))(m) }
}

/// Haskell `($<)` operator.
/// ```
/// ($<) :: f b -> b -> f a
/// ($<) = flip(>$)
/// ```
/// ### Examples
/// ```gleam
/// let o = con.Op(int.to_string)
/// // Doesn't matter what value/type we use for the final apply  
/// [1, 2, 3]
/// |> replace_flip(op_contravariant())(o, 7).apply
/// // -> "7"
/// ```
pub fn replace_flip(
  contravar: Contravariant(_, a, b, fa, fb),
) -> fn(fb, b) -> fa {
  cat.flip(replace(contravar))
}

/// Haskell `phantom` function.
/// ```
/// phantom :: (Functor f, Contravariant f) => f a => f b
/// phantom x = () <$ x $< ()
/// ```
/// If `f `is both `Functor` and `Contravariant`, it can't use its argument in a meaningful way. The laws follow from the preservation of `composition` for `fmap` and `contramap`.
/// ### Laws:
/// - __fmap f = phantom__
/// - __contramap f = phantom__
/// ### Examples
/// ```gleam
/// // Phantom type for the instance
/// pub type UnitF
/// // Construct two instances (functor and covariant) for the same type
/// let unit_functor: Functor(UnitF, _, _, _, Nil) =
///     Functor(fmap: fn(_) { cat.unit })
/// let unit_contravariant: Contravariant(UnitF, _, _, Nil, _) =
///     Contravariant(contramap: fn(_) { cat.unit })
/// // We are left with the instance UnitF
/// // According to the laws of composition for fmap and contramap, this type can't do anything
/// "abc"
/// |> phantom(unit_functor, unit_contravariant)
/// // -> Nil
/// ```
pub fn phantom(
  functor: fun.Functor(f, a, Nil, fa, _),
  contra: Contravariant(f, a, Nil, fb, _),
) -> fn(fa) -> fb {
  fn(x) {
    x
    |> fun.replace(functor)(Nil, _)
    |> replace_flip(contra)(Nil)
  }
}
