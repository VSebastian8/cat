//// `Functor` type {minimal implementation - `fmap`}. \
//// Default implementation for: `replace` (<$ operator). \
//// Functor `composition`.

import cat.{type Pair}

/// `Functor` type in gleam.
/// ```
/// // Haskell type class
/// class Functor f where
///     fmap :: (a -> b) -> f a -> f b
/// ```
/// ### Functor laws
/// - Preservation of `identity`: **fmap id = id**
/// - Preservation of `composition`: **fmap (g ∘ h) = (fmap g) ∘ (fmap h)**
/// 
/// Since gleam does not have `Higher Kinded Types`, we cannot pass the type constructor to the Functor type. \
/// We would like pass Option as f and then use f(a) as a type in the fmap definition.
/// ### Compromise
/// The user will follow this **convention**:
/// - f: the first parameter of the Functor type is a `phantom type` used to differentiate between Functor instances
/// - a, b: the second and third parameters are `generic types`
/// - fa, fb: the fourth and fifth parameters are the `constructed types` **f(a)** and **f(b)** respectively
/// ### Examples 
/// ```gleam
/// // The type that will be an instance of Functor:
/// type Identity(a) {
///   Identity(a)
/// }
/// // The phantom type that will be the first parameter:
/// type IdentityF
/// // Instance of Identity for Functor (defined as a function to keep it generic over a and b)
/// let id_functor = fn() -> Functor(IdentityF, a, b, Identity(a), Identity(b)){
///     Functor(fmap: fn(f) {
///         fn(idx) {
///             let Identity(x) = idx
///             Identity(f(x))
///         }
///     })
/// }
/// // Use: the function id_functor needs to be called twice
/// // Each time it binds a and b (first to Int and Bool, second to Float and String)
/// let f = fn(x: Int) -> Bool { x % 2 == 0 }
/// identity_functor().fmap(f)(Identity(5))
/// // -> Identity(False)
/// let g = fn(x: Float) -> String { float.to_string(x) }
/// identity_functor().fmap(g)(Identity(6.0))
/// // -> Identity("6.0")
/// ```
pub type Functor(f, a, b, fa, fb) {
  Functor(fmap: fn(fn(a) -> b) -> fn(fa) -> fb)
}

/// Haskell `(<$)` operator.
/// ```
/// (<$) :: a -> f b -> f a
/// x <$ m = fmap (const x) m 
/// ```
/// ### Examples
/// ```gleam
/// replace(option_functor())("a", Some(2))
/// // -> Some("a")
/// replace(option_functor())("a", None)
/// // -> None
/// ```
pub fn replace(functor: Functor(_, _, a, fb, fa)) -> fn(a, fb) -> fa {
  fn(x, m) { functor.fmap(cat.constant(x))(m) }
}

/// Functor `composition`. \
/// Is simply the composition of their fmaps.
/// ### Examples
/// ```gleam
/// Some([1, 2, 3])
/// |> functor_compose(option_functor(), list_functor()).fmap
/// ( fn(x) { int.to_string(x + 1) } )
/// // -> Some(["2", "3", "4"])
/// ```
pub fn functor_compose(
  g: Functor(g, fa, fb, gfa, gfb),
  f: Functor(f, a, b, fa, fb),
) -> Functor(Pair(g, f), a, b, gfa, gfb) {
  Functor(fmap: cat.compose(g.fmap, f.fmap))
}
