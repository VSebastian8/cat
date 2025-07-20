//// `Functor` type {minimal implementation - `empty` and `or`}.

/// `Alternative` type, a monoid on applicative functors.
/// ```
/// class Applicative f => Alternative f where
/// empty :: f a
/// (<|>) :: f a -> f a -> f a
/// ```
pub type Alternative(f, fa) {
  Alternative(empty: fa, or: fn(fa, fa) -> fa)
}
