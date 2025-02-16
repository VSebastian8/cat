//// `Writer` and `Reader` types.

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

/// The `identity morphism` for the Writer category.
/// ### Examples
/// ```gleam
/// writer_return(2)
/// // -> Writer(2, "")
/// writer_return("abcd")
/// // -> Writer("abcd", "") 
/// ```
pub fn writer_return(x: a) -> Writer(a) {
  Writer(x, "")
}

/// `Composition` for the embellished functions that return the Writer type.
/// ```
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

/// Encapsulates a function.
/// ```
/// type Reader r a = r -> a
/// ```
/// ### Examples
/// ```gleam
/// let r = Reader(fn(x) { x % 2 == 1 })
/// r.apply(6)
/// // -> False
/// ```
pub type Reader(r, a) {
  Reader(apply: fn(r) -> a)
}

/// The `identity morphism` for the Reader category.
/// ### Examples
/// ```gleam
/// let f = fn(x) {x * 3}
/// reader_return(f)
/// // -> Reader(f)
/// ```
pub fn reader_return(f: fn(r) -> a) -> Reader(r, a) {
  Reader(apply: f)
}
