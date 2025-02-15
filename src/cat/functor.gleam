import gleam/option.{type Option, None, Some}

/// `Functor` type in gleam.
/// ```
/// // Haskell implementation
/// class Functor f where
///     fmap :: (a -> b) -> f a -> f b
/// ```
/// Since gleam does not have `Higher Kinded Types`, we cannot pass the type constructor to the Functor type. \
/// We would like pass Option as f and then use f(a) as a type in the fmap definition.
/// ### Compromise
/// The user will follow this **convention**:
/// - f: the first parameter of the Functor type is a `phantom type` used to differentiate between Functor instances
/// - a, b: the second and third parameters are `generic types`
/// - c, d: the fourth and fifth parameters are the `constructed types` **f(a)** and **f(b)** respectively
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
pub type Functor(f, a, b, c, d) {
  Functor(fmap: fn(fn(a) -> b) -> fn(c) -> d)
}

/// Phantom type for `Option Functor`.
pub type OptionF

/// `Option Functor Instance` (generic over a and b).
/// ### Examples
/// ```gleam
/// let double = fn(x) { x * 2 }
/// option_functor().fmap(double)(None)
/// // -> None
/// Some(2)
/// |> option_functor().fmap(double)
/// // -> Some(4)
/// ```
pub fn option_functor() -> Functor(OptionF, a, b, Option(a), Option(b)) {
  Functor(fmap: option_fmap)
}

/// `Fmap` function for Option Functor. \
/// This function can also be used directly (skipping the wrapper type Functor).
/// ### Examples
/// ```gleam
/// let double = fn(x) { x * 2 }
/// option_fmap(double)(Some(7))
/// // -> Some(14)
/// ```
pub fn option_fmap(f: fn(a) -> b) -> fn(Option(a)) -> Option(b) {
  fn(m) {
    case m {
      None -> None
      Some(x) -> Some(f(x))
    }
  }
}
