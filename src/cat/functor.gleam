import cat.{type Const, Const}
import gleam/option.{type Option, None, Some}

/// `Functor` type in gleam.
/// ```
/// // Haskell type class
/// class Functor f where
///     fmap :: (a -> b) -> f a -> f b
/// ```
/// ### Functor laws
/// - Preservation of `identity`: **fmap id = id**
/// - Preservation of `composition`: **fmap (g . h) = (fmap g) . (fmap h)**
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

/// Functor `composition`. \
/// Is simply the composition of their fmaps.
/// ### Examples
/// ```gleam
/// Some([1, 2, 3])
/// |> functor_compose(list_functor(), option_functor())
/// ( fn(x) { int.to_string(x + 1) } )
/// // -> Some(["2", "3", "4"])
/// ```
pub fn functor_compose(
  g: Functor(_, a, b, ga, gb),
  f: Functor(_, ga, gb, fga, fgb),
) {
  cat.compose(f.fmap, g.fmap)
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

/// Phantom type for `List Functor`.
pub type ListF

/// `fmap` for List Functor.
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
pub fn list_functor() -> Functor(ListF, a, b, List(a), List(b)) {
  Functor(fmap: list_fmap)
}

/// Phantom type for `Reader Functor`.
pub type ReaderF(r)

/// `Reader Functor Instace`.
/// ```
/// // Haskell instance
/// instance Functor ((->) r) where
///     fmap :: (a -> b) -> (r -> a) -> (r -> b)
///     fmap f g = f . g
/// ```
pub fn reader_functor() -> Functor(ReaderF(r), a, b, fn(r) -> a, fn(r) -> b) {
  Functor(fmap: fn(f: fn(a) -> b) -> fn(fn(r) -> a) -> fn(r) -> b {
    fn(g: fn(r) -> a) -> fn(r) -> b { cat.compose(f, g) }
  })
}

/// Phantom type for `Const Functor`. \
/// We bind the first parameter of Const.
pub type ConstF(c)

/// `Const Functor Instance`.
/// ```
/// // Haskell instance
/// instance Functor (Const c) where
///     fmap :: (a -> b) -> Const c a -> Const c b
///     fmap _ (Const v) = Const v  
/// ```
pub fn const_functor() -> Functor(ConstF(c), a, b, Const(c, a), Const(c, b)) {
  Functor(fmap: fn(_: fn(a) -> b) -> fn(Const(c, a)) -> Const(c, b) {
    fn(con) {
      let Const(val) = con
      Const(val)
    }
  })
}
