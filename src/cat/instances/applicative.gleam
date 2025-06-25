//// `Applicative` instances: Identity, Option, List, Const, Tuple, Pair, Either, Triple Writer, Reader, Function.

import cat.{
  type Const, type Either, type Identity, type Pair, type Reader, type Writer,
  Const, Identity, Left, Pair, Reader, Right, Writer, constant,
}
import cat/applicative.{type Applicative, Applicative}
import cat/instances/functor.{
  const_functor, either_functor, function_functor, identity_functor,
  list_functor, option_functor, pair_functor, reader_functor, triple_functor,
  tuple_functor, writer_functor,
}
import cat/instances/types.{
  type ConstF, type EitherF, type FunctionF, type IdentityF, type ListF,
  type OptionF, type PairF, type ReaderF, type TripleF, type TupleF,
  type WriterF,
}
import cat/monoid.{type Monoid}
import gleam/list
import gleam/option.{type Option, None, Some}

/// Applicative instance for `Identity`.
/// ### Examples
/// ```gleam
/// let identity_f =
///   fn(x: Int, y: String) { int.to_string(x) <> y }
///   |> curry()
///   |> identity_applicative().pure()
///
/// identity_applicative().apply(
///   identity_applicative().apply
///      (identity_f)
///      (Identity(6))
/// )(Identity(" apples"))
/// // -> Identity("6 apples")
/// ```
pub fn identity_applicative() -> Applicative(
  IdentityF,
  a,
  b,
  Identity(a),
  Identity(b),
  Identity(fn(a) -> b),
) {
  Applicative(identity_functor(), pure: fn(x) { Identity(x) }, apply: fn(fa) {
    fn(fx) {
      let Identity(f) = fa
      let Identity(x) = fx
      Identity(f(x))
    }
  })
}

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
pub fn option_applicative() -> Applicative(
  OptionF,
  a,
  b,
  Option(a),
  Option(b),
  Option(fn(a) -> b),
) {
  Applicative(option_functor(), pure: fn(x) { Some(x) }, apply: fn(m) {
    case m {
      None -> fn(_) { None }
      Some(f) -> option_functor().fmap(f)
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
pub fn list_applicative() -> Applicative(
  ListF,
  a,
  b,
  List(a),
  List(b),
  List(fn(a) -> b),
) {
  Applicative(list_functor(), pure: fn(x) { [x] }, apply: fn(lf) {
    fn(la) { lf |> list.flat_map(fn(f) { la |> list.map(f) }) }
  })
}

/// Applicative instance for `Const` given `Monoid` instance.
/// ### Examples
/// ```gleam
/// {
///   const_monoid_applicative(all_monoid()).pure(fn(x) { x * 2 }) // True
///   |> const_monoid_applicative(any_monoid()).apply // ||
/// }(const_monoid_applicative(all_monoid()).pure(7)) // False
/// // -> Const(True)
/// ```
pub fn const_monoid_applicative(
  mono: Monoid(m),
) -> Applicative(
  ConstF(m),
  a,
  b,
  Const(m, a),
  Const(m, b),
  Const(m, fn(a) -> b),
) {
  Applicative(
    const_functor(),
    pure: fn(_) { Const(mono.mempty) },
    apply: fn(m1) {
      fn(m2) {
        let Const(val1) = m1
        let Const(val2) = m2
        Const(mono.mappend(val1, val2))
      }
    },
  )
}

/// Applicative instance for `Tuple` given `Monoid` instance.
/// ### Examples
/// ```gleam
/// let sum = int_sum_monoid()
/// {
///   {
///     fn(x) { fn(y) { x * 10 + y } }
///     |> tuple_monoid_applicative(sum).pure()
///     |> tuple_monoid_applicative(sum).apply()
///   }(#(3, 7))
///   |> tuple_monoid_applicative(sum).apply()
/// }(#(2, 4))
/// // -> #(5, 74)
/// ```
pub fn tuple_monoid_applicative(
  mono: Monoid(m),
) -> Applicative(TupleF(m), a, b, #(m, a), #(m, b), #(m, fn(a) -> b)) {
  Applicative(tuple_functor(), pure: fn(x) { #(mono.mempty, x) }, apply: fn(tf) {
    let #(v1, f) = tf
    fn(tx) {
      let #(v2, x) = tx
      #(mono.mappend(v1, v2), f(x))
    }
  })
}

/// Applicative instance for `Pair` given `Monoid` instance.
/// ### Examples
/// ```gleam
/// let prod = int_prod_monoid()
/// {
///   {
///     fn(x) { fn(y) { x * 10 + y } }
///     |> pair_monoid_applicative(prod).pure()
///     |> pair_monoid_applicative(prod).apply()
///   }(Pair(3, 9))
///   |> pair_monoid_applicative(prod).apply()
/// }(Pair(4, 1))
/// // -> Pair(12, 91)
/// ```
pub fn pair_monoid_applicative(
  mono: Monoid(m),
) -> Applicative(PairF(m), a, b, Pair(m, a), Pair(m, b), Pair(m, fn(a) -> b)) {
  Applicative(
    pair_functor(),
    pure: fn(x) { Pair(mono.mempty, x) },
    apply: fn(pf) {
      let Pair(v1, f) = pf
      fn(px) {
        let Pair(v2, x) = px
        Pair(mono.mappend(v1, v2), f(x))
      }
    },
  )
}

/// Applicative instance for `Either`.
/// ### Examples
/// ```gleam
/// let e_plus =
///   fn(x) { x + 2 }
///   |> either_applicative().pure()
///   |> either_applicative().apply()
/// 
/// e_plus(Left("Unexpected"))
/// // -> Left("Unexpected")
/// e_plus(Right(1))
/// // -> Right(3)
/// ```
pub fn either_applicative() -> Applicative(
  EitherF(e),
  a,
  b,
  Either(e, a),
  Either(e, b),
  Either(e, fn(a) -> b),
) {
  Applicative(either_functor(), pure: fn(x) { Right(x) }, apply: fn(ef) {
    fn(ex) {
      case ef {
        Left(err) -> Left(err)
        Right(f) -> either_functor().fmap(f)(ex)
      }
    }
  })
}

/// Applicative instance for `Triple` given 2 `Monoid` instances.
/// ### Examples
/// ```gleam
/// let sum = int_sum_monoid()
/// let prod = int_prod_monoid()
/// let triple_plus =
///   fn(x) { fn(y) { x + y } }
///   |> triple_monoid_applicative(sum, prod).pure()
///   |> triple_monoid_applicative(sum, prod).apply()
/// // Final instance for binding the generic types:
/// let triple = triple_monoid_applicative(sum, prod)
/// // Applicative function chain:
/// triple.apply(triple_plus(#(3, 3, 20)))(#(4, 4, 15))
/// // -> #(7, 12, 35)
/// ```
pub fn triple_monoid_applicative(
  mono1: Monoid(c),
  mono2: Monoid(d),
) -> Applicative(
  TripleF(c, d),
  a,
  b,
  #(c, d, a),
  #(c, d, b),
  #(c, d, fn(a) -> b),
) {
  Applicative(
    triple_functor(),
    pure: fn(x) { #(mono1.mempty, mono2.mempty, x) },
    apply: fn(tf) {
      let #(v1, u1, f) = tf
      fn(tx) {
        let #(v2, u2, x) = tx
        #(mono1.mappend(v1, v2), mono2.mappend(u1, u2), f(x))
      }
    },
  )
}

/// Applicative instance for `Writer`.
/// ### Examples
/// ```gleam
/// let log_plus =
///   Writer(fn(x) { x + 2 }, "[plus two]")
///   |> writer_applicative().apply()
/// 
/// log_plus(Writer(7, " seven"))
/// // -> Writer(9, "[plus two] seven")
/// ```
pub fn writer_applicative() -> Applicative(
  WriterF,
  a,
  b,
  Writer(a),
  Writer(b),
  Writer(fn(a) -> b),
) {
  Applicative(
    writer_functor(),
    pure: fn(x) { Writer(x, "") },
    apply: fn(wf: Writer(fn(a) -> b)) {
      fn(wx: Writer(a)) -> Writer(b) {
        let Writer(f, msg1) = wf
        let Writer(x, msg2) = wx
        Writer(f(x), msg1 <> msg2)
      }
    },
  )
}

/// Applicative instance for `Reader`.
/// ### Examples
/// ```gleam
/// let rff = Reader(fn(x) { fn(y) { x * y } })
/// let rf = Reader(fn(x) { x + 5 })
/// let rg = reader_applicative().apply(rff)(rf)
/// 
/// rg.apply(2) // 2 * (2 + 5)
/// // -> 14
/// ```
pub fn reader_applicative() -> Applicative(
  ReaderF(r),
  a,
  b,
  Reader(r, a),
  Reader(r, b),
  Reader(r, fn(a) -> b),
) {
  Applicative(
    reader_functor(),
    pure: fn(x) { Reader(apply: constant(x)) },
    apply: fn(rg: Reader(r, fn(a) -> b)) {
      fn(f: Reader(r, a)) -> Reader(r, b) {
        Reader(apply: fn(r) { rg.apply(r)(f.apply(r)) })
      }
    },
  )
}

/// Applicative instance for `(->)`.
/// ### Examples
/// ```gleam
/// let ff = fn(x) { fn(y) { x * y } }
/// let f = fn(x) { x + 5 }
/// let g = function_applicative().apply(ff)(f)
/// 
/// g(2) // 2 * (2 + 5)
/// // -> 14
/// ```
pub fn function_applicative() -> Applicative(
  FunctionF(r),
  a,
  b,
  fn(r) -> a,
  fn(r) -> b,
  fn(r) -> fn(a) -> b,
) {
  Applicative(function_functor(), pure: fn(x) { constant(x) }, apply: fn(rg) {
    fn(rf) { fn(r) { rg(r)(rf(r)) } }
  })
}
