import category_theory as ct
import gleam/int
import gleam/io
import gleam/list
import gleeunit
import gleeunit/should

pub fn main() {
  gleeunit.main()
}

/// Useful function for testing
/// range(0, 3) = [0, 1, 2, 3]
fn range(start: Int, finish: Int) -> List(Int) {
  case finish - start {
    0 -> [start]
    _ -> [start, ..range(start + 1, finish)]
  }
}

pub fn identity_test() {
  io.debug("Testing the identity function")
  ct.id(2)
  |> should.equal(2)

  ct.id("abc")
  |> should.equal("abc")

  ct.id(True)
  |> should.equal(True)
}

pub fn composition_test() {
  io.debug("Testing the composition function")
  let y = fn(x: Int) { int.to_string(x) }
  let z = fn(s: String) { s == "28" }
  let h = ct.compose(z, y)

  h(28)
  |> should.equal(True)

  h(29)
  |> should.equal(False)
}

///  f . id == f \
///  id . f == f
pub fn composition_rules_test() {
  io.println("Testing the composition rules")
  let f = fn(x: Int) { x * 5 }

  list.map(range(0, 100), fn(i) {
    ct.compose(ct.id, f)(i)
    |> should.equal(f(i))
  })

  list.map(range(0, 100), fn(i) {
    ct.compose(f, ct.id)(i)
    |> should.equal(f(i))
  })
}
