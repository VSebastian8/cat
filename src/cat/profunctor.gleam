//// `Profunctor` type {minimal implementation - `dimap`} \
//// Default implementations: `lmap` and `rmap`.

import cat

/// `Profunctor`. \
/// A type constructor `p` of two arguments, which is `contra-functorial` in the `first` argument and `functorial` in the `second`.
/// ```
/// // Haskel definition
/// class Profunctor p where
///   dimap :: (a -> b) -> (c -> d) -> p b c -> p a d
///   dimap f g = lmap f ∘ rmap g
///   lmap :: (a -> b) -> p b c -> p a c
///   lmap f = dimap f id
///   rmap :: (c -> d) -> p a c -> p a d
///   rmap = dimap id
/// ```
pub type Profunctor(p, a, b, c, d, pbc, pad) {
  Profunctor(dimap: fn(fn(a) -> b, fn(c) -> d) -> fn(pbc) -> pad)
}

/// Default function `lmap` for a given Profunctor instance.
/// ### Examples
/// ```gleam
/// // Function a -> b ([Int] -> Int)
/// let f = list.fold(_, 0, fn(x, y) { x + y })
/// // Profunctor pbc: Function b -> c (Int -> Bool)
/// let h = fn(x) { x % 2 == 0 }
/// // Profunctor pac: Function a -> c ([Int] -> Bool)
/// let z = lmap(function_profunctor())(f)(h)
/// [1, 2, 3]
/// |> z
/// // -> True
/// [1, 2]
/// |> z
/// // -> False
/// ```
pub fn lmap(
  profunctor: Profunctor(p, a, b, c, c, pbc, pac),
) -> fn(fn(a) -> b) -> fn(pbc) -> pac {
  fn(f) { profunctor.dimap(f, cat.id) }
}

/// Default function `rmap` for a given Profunctor instance.
/// ### Examples
/// ```gleam
/// // Function c -> d (Bool -> String)
/// let g = bool.to_string
/// // Profunctor pac: Function a -> c ([Int] -> Bool)
/// let h = fn(x) { list.length(x) % 2 == 0 }
/// // Profunctor pad: Function ([Int] -> String)
/// let z = rmap(function_profunctor())(g)(h)
/// [1, 2, 3]
/// |> z
/// // -> "False"
/// [1, 2]
/// |> z
/// // -> "True"
/// ```
pub fn rmap(
  profunctor: Profunctor(p, a, a, c, d, pac, pad),
) -> fn(fn(c) -> d) -> fn(pac) -> pad {
  fn(g) { profunctor.dimap(cat.id, g) }
}
