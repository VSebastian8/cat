//// Monad instances: Writer, Reader.

import cat.{type Identity, type Reader, type Writer, Identity, Reader, Writer}
import cat/instances/types.{
  type FunctionF, type IdentityF, type ListF, type OptionF, type ReaderF,
  type ResultF, type WriterF,
}
import cat/monad.{type Monad, Monad, new}
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/result

/// Monad instance for `Identity`.
/// ### Examples
/// ```gleam
/// {
///   use x <- identity_monad().bind(Identity("res: "))
///   use y <- identity_monad().bind(Identity(7))
///   identity_monad().return(x <> int.to_string(y))
/// }
/// // -> Identity("res: 7")
/// // Or without use expressions:
/// identity_monad().bind(Identity("res: "), fn(x) {
///   identity_monad().bind(Identity(7), fn(y) {
///     identity_monad().return(x <> int.to_string(y))
///   })
/// })
/// // -> Identity("res: 7")
/// ```
pub fn identity_monad() -> Monad(IdentityF, a, b, Identity(a), Identity(b)) {
  Monad(
    return: fn(x) { Identity(x) },
    bind: fn(idx, f) {
      let Identity(x) = idx
      f(x)
    },
    map: fn(idx, f) {
      let Identity(x) = idx
      Identity(f(x))
    },
  )
}

/// Monad instance for `Option`.
/// ### Examples
/// ```gleam
/// let op = option_monad()
/// ```
/// ```gleam
/// {
///   use x <- op.bind(Some(2))
///   use y <- op.map(Some(3))
///   x + y
/// }
/// // -> Some(5)
/// ```
/// ```gleam
/// {
///   use x <- op.bind(None)
///   use y <- op.map(Some(3))
///   x + y
/// }
/// // -> None
/// ```
/// ```gleam
/// {
///   use x <- op.bind(Some(2))
///   use y <- op.map(None)
///   x + y
/// }
/// // -> None
/// ```
pub fn option_monad() -> Monad(OptionF, a, b, Option(a), Option(b)) {
  Monad(
    return: fn(x) { Some(x) },
    bind: fn(optx, f) {
      case optx {
        None -> None
        Some(x) -> f(x)
      }
    },
    map: fn(optx, f) {
      case optx {
        None -> None
        Some(x) -> Some(f(x))
      }
    },
  )
}

/// Monad instance for `List`.
/// ### Examples
/// ```gleam
/// let lm = list_monad()
/// {
///   use x <- lm.bind([1, 2, 3])
///   use y <- lm.bind([4, 5])
///   lm.return(x * y)
/// }
/// // -> [4, 5, 8, 10, 12, 15]
/// ```
pub fn list_monad() -> Monad(ListF, a, b, List(a), List(b)) {
  Monad(return: fn(x) { [x] }, bind: list.flat_map, map: list.map)
}

/// Monad instance for `Result`.
/// ### Examples
/// ```gleam
/// let rm = result_monad()
/// {
///   use x <- rm.bind(Ok(2))
///   use y <- rm.map(Ok(3))
///   x + y
/// }
/// ```
/// ```gleam
/// // -> Ok(5)
/// {
///   use x <- rm.bind(Error("Nan"))
///   use y <- rm.map(Ok(3))
///   x + y
/// }
/// ```
/// ```gleam
/// // -> Error("Nan")
/// {
///   use x <- rm.bind(Ok(2))
///   use y <- rm.map(Error("Nan"))
///   x + y
/// }
/// // -> Error("Nan")
/// ```
pub fn result_monad() -> Monad(ResultF(e), a, b, Result(a, e), Result(b, e)) {
  Monad(return: fn(x) { Ok(x) }, bind: result.try, map: result.map)
}

/// Monad instance for `Writer`.
/// ```
/// instance Monad Writer where
///  ma >>= k = 
///   let (va, log1) = runWriter ma
///       (vb, log2) = runWriter (k va)
///   in  Writer (vb, log1 ++ log2)
/// ```
/// ### Examples
/// ```gleam
/// {
///   use x <- writer_monad().bind(Writer(2, "two + "))
///   use y <- writer_monad().map(Writer(3, "three"))
///   x + y
/// }
/// // -> Writer(5, "two + three")
/// ```
pub fn writer_monad() -> Monad(WriterF, a, b, Writer(a), Writer(b)) {
  Monad(
    return: fn(x) { Writer(x, "") },
    bind: fn(wa: Writer(a), f: fn(a) -> Writer(b)) {
      let Writer(x, msg1) = wa
      let Writer(y, msg2) = f(x)
      Writer(y, msg1 <> msg2)
    },
    map: fn(wa: Writer(a), f: fn(a) -> b) {
      let Writer(x, msg) = wa
      Writer(f(x), msg)
    },
  )
}

/// Monad instance for `Reader`.
/// ```
/// instance Monad ((->) r) where
///   f >>= k = \ r -> k (f r) r
/// ```
/// ### Examples
/// ```gleam
/// let r = {
///   use t1 <- reader_monad().bind(Reader(fn(x) { x % 2 == 0 }))
///   use t2 <- reader_monad().map(Reader(fn(x) { x % 3 == 0 }))
///   t1 || t2
/// }
/// r.apply(5)
/// // -> False
/// r.apply(6)
/// // -> True
/// ```
pub fn reader_monad() -> Monad(ReaderF(r), a, b, Reader(r, a), Reader(r, b)) {
  new(
    fn(x) { Reader(cat.constant(x)) },
    fn(x) { Reader(cat.constant(x)) },
    bind: fn(ra: Reader(r, a), f: fn(a) -> Reader(r, b)) {
      Reader(apply: fn(x) { f(ra.apply(x)).apply(x) })
    },
  )
}

/// Monad instance for `(->)`.
/// ### Examples
/// ```gleam
/// let h = {
///   use f <- function_monad().bind(fn(x) { fn(y) { x * y } })
///   use x <- function_monad().map(fn(x) { x + 5 })
///   f(x)
/// }
/// h(2)
/// // -> 14
/// ```
pub fn function_monad() -> Monad(FunctionF(r), a, b, fn(r) -> a, fn(r) -> b) {
  Monad(
    return: fn(x) { fn(_) { x } },
    bind: fn(ra, f) { fn(x) { f(ra(x))(x) } },
    map: fn(ra, f) { fn(x) { f(ra(x)) } },
  )
}
