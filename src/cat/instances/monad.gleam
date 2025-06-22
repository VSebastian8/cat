//// Monad instances: Writer, Reader.

import cat.{type Reader, type Writer, Reader, Writer}
import cat/instances/applicative.{reader_applicative, writer_applicative}
import cat/monad.{Monad}

/// Monad instance for `Reader`.
/// ```
/// instance Monad ((->) r) where
///   f >>= k = \ r -> k (f r) r
///```
pub fn reader_monad() {
  Monad(reader_applicative(), reader_applicative().pure, fn(ra: Reader(r, a)) {
    fn(f: fn(a) -> Reader(r, b)) {
      Reader(apply: fn(x) { f(ra.apply(x)).apply(x) })
    }
  })
}

/// Monad instance for `Writer`.
/// ```
/// instance Monad Writer where
///  ma >>= k = 
///   let (va, log1) = runWriter ma
///       (vb, log2) = runWriter (k va)
///   in  Writer (vb, log1 ++ log2)
/// ```
pub fn writer_monad() {
  Monad(writer_applicative(), fn(x) { Writer(x, "") }, fn(wa: Writer(a)) {
    fn(f: fn(a) -> Writer(b)) {
      let Writer(x, msg1) = wa
      let Writer(y, msg2) = f(x)
      Writer(y, msg1 <> msg2)
    }
  })
}
