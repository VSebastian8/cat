import cat
import gleam/option.{type Option, None, Some}

/// `Functor` type in gleam.
/// ```
/// // Haskell type class
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
/// ```
/// // Haskell instance
/// instance Functor Maybe where
///     fmap :: (a -> b) -> Maybe a -> Maybe b
///     fmap _ Nothing = Nothing
///     fmap f (Just x) = Just (f x)
/// ```
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
  Functor(fmap: fn(f: fn(a) -> b) -> fn(Option(a)) -> Option(b) {
    fn(m) {
      case m {
        None -> None
        Some(x) -> Some(f(x))
      }
    }
  })
}

/// Phantom type for `List Functor`
pub type ListF

/// `fmap` for List Functor.
/// ```gleam
/// // fmap is similar to list.map()
/// ```
fn list_fmap(f: fn(a) -> b) -> fn(List(a)) -> List(b) {
  fn(l) {
    case l {
      [] -> []
      [x, ..rest] -> [f(x), ..list_fmap(f)(rest)]
    }
  }
}

/// `List Functor Instance`.
/// ```
/// // Haskell instance
/// instance Functor [] where
///     fmap :: (a -> b) -> [a] -> [b]
///     fmap _ [] = []
///     fmap f (x:xs) = (f x):(fmap f xs)
/// ```
/// ### Examples
/// ```gleam
/// ```
pub fn list_functor() -> Functor(ListF, a, b, List(a), List(b)) {
  Functor(fmap: list_fmap)
}

/// Phantom type for `Reader Functor`
pub type ReaderF

/// `Reader Functor Instace`.
/// ```
/// // Haskell instance
/// instance Functor ((->) r) where
///     fmap :: (a -> b) -> (r -> a) -> (r -> b)
///     fmap f g = f . g
/// ```
/// ### Examples
/// ```gleam
/// ```
pub fn reader_functor() -> Functor(ReaderF, a, b, fn(r) -> a, fn(r) -> b) {
  Functor(fmap: fn(f: fn(a) -> b) -> fn(fn(r) -> a) -> fn(r) -> b {
    fn(g: fn(r) -> a) -> fn(r) -> b { cat.compose(f, g) }
  })
}
