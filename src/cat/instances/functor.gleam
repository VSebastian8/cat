//// `Functor` instances: Option, List, Reader, Writer, Const, Tuple, Triple, Pair, Either.

import cat.{
  type Const, type Either, type Identity, type Pair, type Reader, type Writer,
  Const, Identity, Left, Pair, Reader, Right, Writer, fish,
}
import cat/functor.{type Functor, Functor}
import cat/instances/types.{
  type ConstF, type EitherF, type FunctionF, type IdentityF, type ListF,
  type OptionF, type PairF, type ReaderF, type ResultF, type TripleF,
  type TupleF, type WriterF,
}
import gleam/option.{type Option, None, Some}

/// `Identity Functor Instance`.
/// ```
/// // Haskell implementation
/// instance Functor Maybe where
///     fmap :: (a -> b) -> Identity a -> Identity b
///     fmap f (Identity x) = Identity(f x)
/// ```
/// ### Examples
/// ```gleam
/// let f = fn(x: Int) -> Bool { x % 2 == 0 }
/// identity_functor().fmap(f)(Identity(5))
/// // -> Identity(False)
/// ```
pub fn identity_functor() -> Functor(IdentityF, a, b, Identity(a), Identity(b)) {
  Functor(fmap: fn(f) {
    fn(idx) {
      let Identity(x) = idx
      Identity(f(x))
    }
  })
}

/// `Option Functor Instance` (generic over a and b).
/// ```
/// // Haskell instance
/// instance Functor Maybe where
///     fmap :: (a -> b) -> Maybe a -> Maybe b
///     fmap _ Nothing = Nothing
///     fmap f (Just x) = Just (f x)
/// ```
/// ### Examples
/// ```gleam
/// let double = fn(x) { x * 2 }
/// option_functor().fmap(double)(None)
/// // -> None
/// Some(2)
/// |> option_functor().fmap(double)
/// // -> Some(4)
/// ```
pub fn option_functor() -> Functor(OptionF, a, b, Option(a), Option(b)) {
  Functor(fmap: fn(f: fn(a) -> b) -> fn(Option(a)) -> Option(b) {
    fn(m) {
      case m {
        None -> None
        Some(x) -> Some(f(x))
      }
    }
  })
}

/// `Result Functor Instance`.
/// ### Examples
/// ```gleam
/// result_functor().fmap(int.to_string)(Ok(72))
/// // -> Ok("72")
/// result_functor().fmap(int.to_string)(Error("Not a number"))
/// // -> Error("Not a number")
/// ```
pub fn result_functor() -> Functor(ResultF(e), a, b, Result(a, e), Result(b, e)) {
  Functor(fmap: fn(f) {
    fn(res) {
      case res {
        Error(err) -> Error(err)
        Ok(x) -> Ok(f(x))
      }
    }
  })
}

/// `fmap` for List Functor.
fn list_fmap(f: fn(a) -> b) -> fn(List(a)) -> List(b) {
  fn(l) {
    case l {
      [] -> []
      [x, ..rest] -> [f(x), ..list_fmap(f)(rest)]
    }
  }
}

/// `List Functor Instance`.
/// ```
/// // Haskell instance
/// instance Functor [] where
///     fmap :: (a -> b) -> [a] -> [b]
///     fmap _ [] = []
///     fmap f (x:xs) = (f x):(fmap f xs)
/// ```
/// ### Examples
/// ```gleam
/// list_functor().fmap(int.to_string)([1, 3, 4])
/// // -> ["1", "3", "4"]
/// ```
pub fn list_functor() -> Functor(ListF, a, b, List(a), List(b)) {
  Functor(fmap: list_fmap)
}

/// `Const Functor Instance`.
/// ```
/// // Haskell instance
/// instance Functor (Const c) where
///     fmap :: (a -> b) -> Const c a -> Const c b
///     fmap _ (Const v) = Const v  
/// ```
/// ### Examples
/// ```gleam
/// const_functor().fmap(int.to_string)(Const(True))
/// // -> Const(True)
/// ```
pub fn const_functor() -> Functor(ConstF(c), a, b, Const(c, a), Const(c, b)) {
  Functor(fmap: fn(_: fn(a) -> b) -> fn(Const(c, a)) -> Const(c, b) {
    fn(con) {
      let Const(val) = con
      Const(val)
    }
  })
}

/// `Tuple Functor`.
/// ### Examples
/// ```gleam
/// tuple_functor().fmap(bool.negate)(#(9, False))
/// // -> #(9, True)
/// ```
pub fn tuple_functor() -> Functor(TupleF(c), a, b, #(c, a), #(c, b)) {
  Functor(fmap: fn(f: fn(a) -> b) -> fn(#(c, a)) -> #(c, b) {
    fn(p: #(c, a)) { #(p.0, f(p.1)) }
  })
}

/// `Pair Functor`.
/// ### Examples
/// ```gleam
/// pair_functor().fmap(bool.negate)(Pair(9, False))
/// // -> Pair(9, True)
/// ```
pub fn pair_functor() -> Functor(PairF(c), a, b, Pair(c, a), Pair(c, b)) {
  Functor(fmap: fn(f: fn(a) -> b) -> fn(Pair(c, a)) -> Pair(c, b) {
    fn(p) {
      let Pair(x, y) = p
      Pair(x, f(y))
    }
  })
}

/// `Either Functor`.
/// ### Examples
/// ```gleam
/// either_functor().fmap(bool.negate)(Left(27))
/// // -> Left(27)
/// either_functor().fmap(bool.negate)(Right(False))
/// // -> Right(True)
/// ```
pub fn either_functor() -> Functor(EitherF(e), a, b, Either(e, a), Either(e, b)) {
  Functor(fmap: fn(f: fn(a) -> b) -> fn(Either(e, a)) -> Either(e, b) {
    fn(e) {
      case e {
        Left(x) -> Left(x)
        Right(y) -> Right(f(y))
      }
    }
  })
}

/// `Triple Functor`.
/// ### Examples
/// ```gleam
/// triple_functor().fmap(bool.negate)(#("abc", 9, False))
/// // -> #("abc", 9, True)
/// ```
pub fn triple_functor() -> Functor(TripleF(c, d), a, b, #(c, d, a), #(c, d, b)) {
  Functor(fmap: fn(f: fn(a) -> b) -> fn(#(c, d, a)) -> #(c, d, b) {
    fn(p: #(c, d, a)) { #(p.0, p.1, f(p.2)) }
  })
}

/// `Writer Functor Instance`.
/// ```
/// // Haskell Instance
/// fmap :: (a -> b) -> Writer a -> Writer b
/// fmap f = id >=> (\x -> return (f x))
/// ```
/// ### Examples
/// ```gleam
/// monad.Writer(16, "message")
/// |> writer_functor().fmap(fn(x) { x % 4 == 0 })
/// // -> monad.Writer(True, "message")
/// ```
pub fn writer_functor() -> Functor(WriterF, a, b, Writer(a), Writer(b)) {
  Functor(fmap: fn(f: fn(a) -> b) {
    fish(cat.id, cat.compose(fn(x) { Writer(x, "") }, f))
  })
}

/// `Reader Functor Instance`.
/// ```
/// // Haskell implementation
/// instance Functor (Reader r) where
///   fmap :: (a -> b) -> Reader r a -> Reader r b
///   fmap f g = f ∘ g
/// ```
/// ### Examples
/// ```gleam
/// let ra = Reader(fn(x) { x % 2 == 0 })
/// let f = bool.to_string
///
/// reader_functor().fmap(f)(ra).apply(19)
/// // -> "False"
/// ```
pub fn reader_functor() -> Functor(ReaderF(r), a, b, Reader(r, a), Reader(r, b)) {
  Functor(fmap: fn(f: fn(a) -> b) {
    fn(ra: Reader(r, a)) -> Reader(r, b) {
      let Reader(g) = ra
      Reader(cat.compose(f, g))
    }
  })
}

/// `(->) Functor Instance`.
/// ```
/// // Haskell instance
/// instance Functor ((->) r) where
///     fmap :: (a -> b) -> (r -> a) -> (r -> b)
///     fmap f g = f ∘ g
/// ```
/// ### Examples
/// ```gleam
/// let f = fn(x) { x % 2 == 0 }
/// let g = bool.to_string
/// 
/// function_functor().fmap(g)(f)(19)
/// // -> "False"
/// ```
pub fn function_functor() -> Functor(FunctionF(r), a, b, fn(r) -> a, fn(r) -> b) {
  Functor(fmap: fn(f: fn(a) -> b) -> fn(fn(r) -> a) -> fn(r) -> b {
    fn(g: fn(r) -> a) -> fn(r) -> b { cat.compose(f, g) }
  })
}
