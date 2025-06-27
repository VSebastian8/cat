//// Monad instances: Writer, Reader.

import cat.{type Identity, type Reader, type Writer, Identity, Reader, Writer}
import cat/instances/types.{
  type IdentityF, type ListF, type OptionF, type ReaderF, type WriterF,
}
import cat/monad.{type Monad, Monad, new}
import gleam/list
import gleam/option.{type Option, None, Some}

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

/// Monad instance for `Writer`.
/// ```
/// instance Monad Writer where
///  ma >>= k = 
///   let (va, log1) = runWriter ma
///       (vb, log2) = runWriter (k va)
///   in  Writer (vb, log1 ++ log2)
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
///```
pub fn reader_monad() -> Monad(ReaderF(r), a, b, Reader(r, a), Reader(r, b)) {
  new(
    fn(x) { Reader(cat.constant(x)) },
    fn(x) { Reader(cat.constant(x)) },
    bind: fn(ra: Reader(r, a), f: fn(a) -> Reader(r, b)) {
      Reader(apply: fn(x) { f(ra.apply(x)).apply(x) })
    },
  )
}
