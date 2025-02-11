import gleam/io
import gleam/list

/// The `identity function` is a `unit of composition`.
/// ```haskell
/// id :: a -> a
/// id a = a
/// ```
/// It follows the identity conditions:
/// - f . id == f
/// - id . f == f
/// ### Examples
/// ```gleam
/// id(3)
/// // -> 3
/// id("abc")
/// // -> "abc"
/// ```
pub fn id(x: a) -> a {
  x
}

/// Given a function `f` that takes an argument of type A and returns a B, and another function `g` that takes a B and returns a C, you can `compose` them by `passing the result of f to g`. 
/// ```haskell
/// (.) :: (b -> c) -> (a -> b) -> (a -> c)
/// (g . f) x = f (g x)
/// ```
/// Properties of composition:
/// - Associativity h . (g . f) == (h . g) . f == h . g . f
/// - Identity see [`id`](#id) for more info
/// ### Examples
/// ```gleam
/// let f = fn(x: Int) { int.to_string(x) }
/// let g = fn(s: String) { s == "28" }
/// let h = compose(g, f)
/// // -> h takes an int, transforms it into a string, then compares it to "28" and returns a bool
/// ``` 
pub fn compose(g: fn(b) -> c, f: fn(a) -> b) -> fn(a) -> c {
  fn(x: a) { g(f(x)) }
}

/// A type corresponding to an `empty set`. It is `not inhabited` by any values.
pub type Void {
  Void(Void)
}

/// A function that can `never` be called. It is polymorphic in the return type. 
pub fn absurd(_: Void) -> a {
  panic
}

/// A function from any type to a unit (Nil in gleam)
/// ```haskell
/// unit :: a -> ()
/// unit _ = ()
/// ```
/// ### Examples
/// ```gleam
/// unit(42)
/// // -> Nil
/// unit(True)
/// // -> Nil
/// ```
pub fn unit(_: t) {
  Nil
}

/// A `two-element set`
/// ```haskell
/// data Bool = True | False
/// ```
pub type Boole {
  TrueB
  FalseB
}

/// A monoid is a `set` with a `binary operation` or a a `single object category` with a `set of morphisms` that follow the rules of composition.
/// ```haskell
/// class Monoid m where
///   mempty  :: m
///   mappend :: m -> m -> m
/// ```
/// Laws:
/// - mappend mempty x = x
/// - mappend x mempty = x
/// - mappend x (mappend y z) = mappend (mappend x y) z
/// - mconcat = foldr mappend mempty
/// ### Examples
/// ```gleam
/// let int_sum_monoid = Monoid(mempty: 0, mappend: fn(x: Int, y: Int) { x + y })
/// int_sum_monoid
/// |> mconcat([2, 3, int_sum_monoid.mempty, 4])
/// |> int_sum_monoid.mappend(10)
/// // -> 19
/// let bool_and_monoid = Monoid(mempty: True, mappend: bool.and)
/// True
/// |> bool_and_monoid.mappend(False)
/// |> bool_and_monoid.mappend(bool_and_monoid.mempty)
/// // -> False
/// ```
pub type Monoid(m) {
  Monoid(mempty: m, mappend: fn(m, m) -> m)
}

// Separate function because gleam doesn't allow default implementations for record fields
/// Fold a `list of monoids` using mappend. 
pub fn mconcat(mono: Monoid(m), monoid_list: List(m)) -> m {
  monoid_list |> list.fold(mono.mempty, mono.mappend)
}

pub fn main() {
  io.println("Category Theory!")
}
