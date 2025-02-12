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

/// Encapsulates a pair whose first component is a `value` of arbitrary type a and the second component is a `string`. \
/// Used to `embellish` the return values of functions.
/// ### Examples
/// ```gleam
/// // Original function
/// f = fn(x) {x * 2}
/// // Embellished function
/// f = fn(x) {Writer(x * 2, "doubled ")}
/// ```
pub type Writer(a) {
  Writer(a, String)
}

/// `Composition` for the embellished functions that return the Writer type.
/// ```haskell
/// (>=>) :: (a -> Writer b) -> (b -> Writer c) -> (a -> Writer c)
/// m1 >=> m2 = \x -> 
///   let (y, s1) = m1 x
///       (z, s2) = m2 y
///   in (z, s1 ++ s2)
/// ```
/// ### Examples
/// ```gleam
/// let up_case = fn(s: String) { Writer(string.uppercase(s), "upCase ") }
/// let to_words = fn(s: String) { Writer(string.split(s, " "), "toWords ") }
/// let process = fish(up_case, to_words)
/// process("Anna has apples")
/// // -> Writer(["ANNA", "HAS", "APPLES"], "upCase toWords ")
/// ```
pub fn fish(
  m1: fn(a) -> Writer(b),
  m2: fn(b) -> Writer(c),
) -> fn(a) -> Writer(c) {
  fn(x) {
    let Writer(y, s1) = m1(x)
    let Writer(z, s2) = m2(y)
    Writer(z, s1 <> s2)
  }
}

/// The `identity morphism` for the Writer category.
/// ### Examples
/// ```gleam
/// return(2)
/// // -> Writer(2, "")
/// return("abcd")
/// // -> Writer("abcd", "") 
/// ```
pub fn return(x: a) -> Writer(a) {
  Writer(x, "")
}

pub fn main() {
  io.println("Category Theory!")
}
