//// `Applicative` instances: Option, List.

import cat/applicative.{new}
import cat/instances/functor.{list_functor, option_functor}
import gleam/list
import gleam/option

/// Instance for `Applicative Option`.
/// ```
/// instance Applicative Maybe where
///     // pure :: a -> Maybe a
///     pure x = Just x
///     // (<*>) :: Maybe (a -> b) -> Maybe a -> Maybe b 
///     Nothing <*> _ = Nothing
///     Just(f) <*> m = fmap f m
/// ```
/// ### Examples
/// ```gleam
/// 9
/// |> { option_applicative() |> pure() }
/// // -> Some(9)
/// let option_f =
///     int.to_string
///     |> { option_applicative() |> pure() }
///     |> { option_applicative() |> apply() }
/// None 
/// |> option_f()
/// // -> None
/// Some(12) 
/// |> option_f()
/// // -> Some("12")
/// ```
pub fn option_applicative() {
  let functor = option_functor
  new(functor, fn(x) { option.Some(x) }, fn(m) {
    case m {
      option.None -> fn(_) { option.None }
      option.Some(f) -> functor().fmap(f)
    }
  })
}

/// Instance for `Applicative List`.
/// ```
/// instance Applicative [] where
///     // pure :: a -> [a]
///     pure x = [x]
///     // (<*>) :: [a -> b] -> [a] -> [b]
///     fs <*> xs = [f x | f <- fs, x <- xs]
/// ```
/// ### Examples
/// ```gleam
/// [1, 2, 3]
/// |> {
///     [fn(x) { x * 2 }, fn(x) { x + 10 }]
///     |> apply(list_applicative())
/// }
/// // -> [2, 4, 6, 11, 12, 13]
/// ```
pub fn list_applicative() {
  let functor = list_functor
  new(functor, fn(x) { [x] }, fn(lf) {
    fn(la) { lf |> list.flat_map(fn(f) { la |> list.map(f) }) }
  })
}
