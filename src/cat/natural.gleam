//// `NaturalTransformation` type {minimal implementation `transform`}. \
//// `Composition` function with a few examples of natural transformations between functors.

import cat.{type Const, Const}
import cat/functor.{type ConstF, type ListF, type OptionF}
import gleam/list
import gleam/option.{type Option, None, Some}

/// A natural transformation of `two functors` **F** and **G** is a collection of functions such that for every type **a** we have a function (`component`) that goes from **F a** to **G a**.\
/// This implementation in gleam is a bit more restrictive in that each `component` is an instantiation of the `generic` function **transform** for the type **a**.
/// ### Examples
/// A natural transformation from `Option` to `List` will contain a `transform` function that, for any type `a`, takes an `Option(a)` and returns a `List(a)`. 
/// ```gleam
/// transform: fn(Option(a)) -> List(a)
/// ```
pub type NaturalTransformation(f, g, fa, ga) {
  NaturalTransformation(transform: fn(fa) -> ga)
}

/// `Composition` of two `natural transformations`.
/// ### Examples
/// ```gleam
/// let maybe_const = 
///   transformation_composition(
///     option_list_transformation(),
///     list_length_transformation()
///   )
/// None
/// |> maybe_const.transform()
/// // -> Const(0)
/// Some("abc")
/// |> maybe_const.transform()
/// // -> Const(1)
/// ```
pub fn transformation_composition(
  alpha: NaturalTransformation(f, g, fa, ga),
  beta: NaturalTransformation(g, h, ga, ha),
) -> NaturalTransformation(f, h, fa, ha) {
  NaturalTransformation(transform: cat.compose(beta.transform, alpha.transform))
}

/// Natural transformation from `Option` to `List`.
/// ### Examples
/// ```gleam
/// None
/// |> option_list_transformation().transform()
/// // -> []
/// Some(7)
/// |> option_list_transformation().transform()
/// // -> [7]
/// ```
pub fn option_list_transformation() -> NaturalTransformation(
  OptionF,
  ListF,
  Option(a),
  List(a),
) {
  NaturalTransformation(transform: fn(m) {
    case m {
      None -> []
      Some(x) -> [x]
    }
  })
}

/// Natural transformation from `List` to `Option`.
/// ### Examples
/// ```gleam
/// []
/// |> list_option_head_transformation().transform()
/// // -> None
/// [1, 2, 3]
/// |> list_option_head_transformation().transform()
/// // -> Some(1)
/// ```
pub fn list_option_head_transformation() -> NaturalTransformation(
  ListF,
  OptionF,
  List(a),
  Option(a),
) {
  NaturalTransformation(transform: fn(l) {
    case l {
      [] -> None
      [x, ..] -> Some(x)
    }
  })
}

/// Natural transformation from `List` to `Const Int`.
/// ### Examples
/// ```gleam
/// []
/// |> list_length_transformation().transform()
/// // -> Const(0)
/// [1, 2, 3, 4]
/// |> list_length_transformation().transform()
/// // -> Const(4)
/// ```
pub fn list_length_transformation() -> NaturalTransformation(
  ListF,
  ConstF(Int),
  List(a),
  Const(Int, a),
) {
  NaturalTransformation(transform: fn(l) { Const(list.length(l)) })
}
