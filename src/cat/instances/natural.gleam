//// Examples of `transformations` between `functors`.

import cat.{Const}
import cat/instances/functor.{const_functor, list_functor, option_functor}
import cat/natural.{NaturalTransformation}
import gleam/list
import gleam/option.{None, Some}

/// Natural transformation from `Option` to `List`.
/// ### Examples
/// ```gleam
/// None
/// |> {option_list_transformation() |> transform()}
/// // -> []
/// Some(7)
/// |> {option_list_transformation() |> transform()}
/// // -> [7]
/// ```
pub fn option_list_transformation() {
  NaturalTransformation(option_functor(), list_functor(), fn(m) {
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
/// |> {list_option_head_transformation() |> transform()}
/// // -> None
/// [1, 2, 3]
/// |> {list_option_head_transformation() |> transform()}
/// // -> Some(1)
/// ```
pub fn list_option_head_transformation() {
  NaturalTransformation(list_functor(), option_functor(), fn(l) {
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
/// |> {list_length_transformation() |> transform()}
/// // -> Const(0)
/// [1, 2, 3, 4]
/// |> {list_length_transformation() |> transform()}
/// // -> Const(4)
/// ```
pub fn list_length_transformation() {
  NaturalTransformation(list_functor(), const_functor(), fn(l) {
    Const(list.length(l))
  })
}
