import cat/alternative.{type Alternative, Alternative}
import cat/functor.{type Functor}
import cat/instances/types.{type ListF, type OptionF, type ResultF}
import cat/monoid.{type Monoid}
import gleam/option.{type Option, None, Some}

/// Alternative instance for `Option`.
/// ### Examples
/// ```gleam
/// option_alternative().or(Some(2), Some(3))
/// // -> Some(2)
/// ```
/// ```gleam
/// option_alternative().or(Some(2), None)
/// // -> Some(2)
/// ```
/// ```gleam
/// option_alternative().or(None, Some(3))
/// // -> Some(3)
/// ```
/// ```gleam
/// option_alternative().or(None, None)
/// // -> None
/// ```
pub fn option_alternative() -> Alternative(OptionF, Option(a)) {
  Alternative(empty: None, or: fn(x, y) {
    case x {
      Some(_) -> x
      None -> y
    }
  })
}

/// Alternative instance for `List`.
/// ### Examples
/// ```gleam
/// list_alternative().or([1, 2, 3], [4, 5, 6])
/// // -> [1, 2, 3]
/// ```
/// ```gleam
/// list_alternative().or([1, 2, 3], [])
/// // -> [1, 2, 3]
/// ```
/// ```gleam
/// list_alternative().or([], [4, 5, 6])
/// // -> [4, 5, 6]
/// ```
/// ```gleam
/// list_alternative().or([], [])
/// // -> []
/// ```
pub fn list_alternative() -> Alternative(ListF, List(a)) {
  Alternative(empty: [], or: fn(x, y) {
    case x {
      [] -> y
      _ -> x
    }
  })
}

/// Alternative instance for `Result`.
/// ### Examples
/// ```gleam
/// result_alternative("").or(Ok(2), Ok(3))
/// // -> Ok(2)
/// ```
/// ```gleam 
/// result_alternative("").or(Ok(2), Error("Nan"))
/// // -> Ok(2)
/// ```
/// ```gleam
/// result_alternative("").or(Error("Nan"), Ok(3))
/// // -> Ok(3)
/// ```
/// ```gleam
/// result_alternative("err").or(Error("Nan"), Error("Nan"))
/// // -> Error("Nan")
/// ```
pub fn result_alternative(error: e) -> Alternative(ResultF(e), Result(a, e)) {
  Alternative(empty: Error(error), or: fn(x, y) {
    case x {
      Error(_) -> y
      _ -> x
    }
  })
}

/// Alternative instance for `Monoid` + `Functor`.
/// ### Examples
/// ```gleam
/// let inst = monoid_functor_alternative(list_monoid(), list_functor())
/// inst.or(inst.empty, [1, 2, 3])
/// // -> [1, 2, 3]
/// inst.or([1, 2], [3, 4, 5])
/// // -> [1, 2, 3, 4, 5]
/// ```
pub fn monoid_functor_alternative(
  mono: Monoid(fa),
  _: Functor(f, a, b, fa, fb),
) -> Alternative(f, fa) {
  Alternative(empty: mono.mempty, or: mono.mappend)
}
