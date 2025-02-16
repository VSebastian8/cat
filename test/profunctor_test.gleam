import cat/profunctor as pro
import gleam/bool
import gleam/list
import gleeunit/should

/// Testing the function profunctor instance.
pub fn function_profunctor_test() {
  // Function a -> b ([Int] -> Int)
  let f = list.fold(_, 0, fn(x, y) { x + y })
  // Function c -> d (Bool -> String)
  let g = bool.to_string
  // Profunctor pbc: Function b -> c (Int -> Bool)
  let h = fn(x) { x % 2 == 0 }
  // Resulting Profunctor pad: Function ([Int] -> String)
  let z = pro.function_profunctor().dimap(f, g)(h)

  [1, 2, 3]
  |> z
  |> should.equal("True")

  [1, 2]
  |> z
  |> should.equal("False")
}

/// Testing the lmap function.
pub fn lmap_test() {
  // Function a -> b ([Int] -> Int)
  let f = list.fold(_, 0, fn(x, y) { x + y })
  // Profunctor pbc: Function b -> c (Int -> Bool)
  let h = fn(x) { x % 2 == 0 }
  // Resulting Profunctor pac: Function a -> c ([Int] -> Bool)
  let z = pro.lmap(pro.function_profunctor())(f)(h)

  [1, 2, 3]
  |> z
  |> should.equal(True)

  [1, 2]
  |> z
  |> should.equal(False)
}

/// Testing the rmap function.
pub fn rmap_test() {
  // Function c -> d (Bool -> String)
  let g = bool.to_string
  // Profunctor pac: Function a -> c ([Int] -> Bool)
  let h = fn(x) { list.length(x) % 2 == 0 }
  // Resulting Profunctor pad: Function ([Int] -> String)
  let z = pro.rmap(pro.function_profunctor())(g)(h)

  [1, 2, 3]
  |> z
  |> should.equal("False")

  [1, 2]
  |> z
  |> should.equal("True")
}
