//// `Monoid` type {minimal implementation - `mempty` and `mappend`}. \
//// Default implementation for the `mconcat` function (defined in terms of mempty and mappend).

import gleam/list

/// A monoid is a `set` with a `binary operation` or a a `single object category` with a `set of morphisms` that follow the rules of composition.
/// ```
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
