import gleam/bool
import gleam/int
import gleam/io

/// Identity Function \
/// id :: a -> a \
/// id a = a
pub fn id(x: a) -> a {
  x
}

/// Composition Function \
/// (.) :: (b -> c) -> (a -> b) -> (a -> c) \
/// (g . f) x = f (g x)
pub fn compose(g: fn(b) -> c, f: fn(a) -> b) -> fn(a) -> c {
  fn(x: a) { g(f(x)) }
}

pub fn unit(_: t) {
  Nil
}

pub fn main() {
  io.println("Category Theory!")
  io.println("Identity Function:")
  let x = 27
  io.println("id(" <> int.to_string(x) <> ") = " <> int.to_string(id(x)))
  io.println("Composition Function:")
  let y = fn(x: Int) { int.to_string(x) }
  let z = fn(s: String) { s == "28" }
  let h = compose(z, y)
  io.println("z . y (" <> int.to_string(x) <> ") = " <> bool.to_string(h(x)))
}
