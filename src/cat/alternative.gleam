//// `Alternative` type {minimal implementation - `empty` and `or`}.\
//// Default implementation for the `fold` function.

import gleam/list

/// `Alternative` type, a monoid on applicative functors.
/// ```
/// class Applicative f => Alternative f where
/// empty :: f a
/// (<|>) :: f a -> f a -> f a
/// ```
/// This type can be useful when working with operations that may fail/return no results
/// ```
/// empty <|> a == a
/// a <|> empty == a
/// a <|> b == a
/// empty <|> empty == empty
/// ```
pub type Alternative(f, fa) {
  Alternative(empty: fa, or: fn(fa, fa) -> fa)
}

/// Function used on a list of alternative values.
/// ### Examples
/// ```gleam
/// fold(option_alternative(), [None, None, Some(2), Some(3), None])
/// // -> Some(2)
/// ```
/// ```gleam
/// fold(option_alternative(), [None, None, None])
/// // -> None
/// ```
/// ```gleam
/// fold(option_alternative(), [])
/// // -> None
/// ```
pub fn fold(a: Alternative(f, fa), l: List(fa)) -> fa {
  list.fold(l, a.empty, a.or)
}
