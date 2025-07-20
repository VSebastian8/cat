//// `Functor` type {minimal implementation - `empty` and `or`}.

/// `Alternative` type, a monoid on applicative functors.
/// ```
/// class Applicative f => Alternative f where
/// empty :: f a
/// (<|>) :: f a -> f a -> f a
/// ```
/// This type can be useful when working with operations that may fail/ return no results
/// ```
/// empty <|> a == a
/// a <|> empty == a
/// a <|> b == a
/// empty <|> empty == empty
/// ```
pub type Alternative(f, fa) {
  Alternative(empty: fa, or: fn(fa, fa) -> fa)
}
