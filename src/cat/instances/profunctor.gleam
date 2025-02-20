//// Profunctor instance for `function type`.

import cat
import cat/profunctor.{type Profunctor, Profunctor}

/// Phantom type for the `function profunctor`.
pub type ArrowPro

/// `Profunctor` instance for the `function type` (->).
/// ```
/// // Haskell implementation
/// instance Profunctor (->) where
///   dimap ab cd bc = cd ∘ bc ∘ ab
///   lmap = flip (∘)
///   rmap = (∘)
/// ```
/// ### Examples
/// ```gleam
/// // Function a -> b ([Int] -> Int)
/// let f = list.fold(_, 0, fn(x, y) { x + y })
/// // Function c -> d (Bool -> String)
/// let g = bool.to_string
/// // Profunctor pbc: Function b -> c (Int -> Bool)
/// let h = fn(x) { x % 2 == 0 }
/// // Profunctor pad: Function a -> d ([Int] -> String)
/// let z = function_profunctor().dimap(f, g)(h)
/// [1, 2, 3]
/// |> z
/// // -> "True"
/// [1, 2]
/// |> z
/// // -> "False"
/// ```
pub fn function_profunctor() -> Profunctor(
  ArrowPro,
  a,
  b,
  c,
  d,
  fn(b) -> c,
  fn(a) -> d,
) {
  Profunctor(dimap: fn(ab: fn(a) -> b, cd: fn(c) -> d) {
    fn(bc: fn(b) -> c) { cat.compose(cd, cat.compose(bc, ab)) }
  })
}
