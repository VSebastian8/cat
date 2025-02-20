//// `Functor` instances: Option, List, Reader, Const, Tuple, Triple, Pair, Either.

import cat.{
  type Const, type Either, type Identity, type Pair, Const, Identity, Left, Pair,
  Right,
}
import cat/functor.{type Functor, Functor}
import cat/instances/monad
import gleam/option.{type Option, None, Some}

// Phantom type for `Identity Functor`.
pub type IdentityF

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

/// Phantom type for `Option Functor`.
pub type OptionF

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

/// Phantom type for `List Functor`.
pub type ListF

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
pub fn list_functor() -> Functor(ListF, a, b, List(a), List(b)) {
  Functor(fmap: list_fmap)
}

/// Phantom type for `Const Functor`. \
/// We bind the first parameter of Const.
pub type ConstF(c)

/// `Const Functor Instance`.
/// ```
/// // Haskell instance
/// instance Functor (Const c) where
///     fmap :: (a -> b) -> Const c a -> Const c b
///     fmap _ (Const v) = Const v  
/// ```
pub fn const_functor() -> Functor(ConstF(c), a, b, Const(c, a), Const(c, b)) {
  Functor(fmap: fn(_: fn(a) -> b) -> fn(Const(c, a)) -> Const(c, b) {
    fn(con) {
      let Const(val) = con
      Const(val)
    }
  })
}

/// Phantom type for `Tuple Functor`.
pub type TupleF(a)

/// `Tuple Functor`.
/// ### Examples
/// ```gleam
/// tuple_functor().fmap(bool.negate)(#(9, False))
/// // -> #(9, True)
/// ```
pub fn tuple_functor() -> Functor(TupleF(a), b, c, #(a, b), #(a, c)) {
  Functor(fmap: fn(f: fn(b) -> c) -> fn(#(a, b)) -> #(a, c) {
    fn(p: #(a, b)) { #(p.0, f(p.1)) }
  })
}

/// Phantom type for `Pair Functor`.
pub type PairF(a)

/// `Pair Functor`.
/// ### Examples
/// ```gleam
/// pair_functor().fmap(bool.negate)(Pair(9, False))
/// // -> Pair(9, True)
/// ```
pub fn pair_functor() -> Functor(PairF(a), b, c, Pair(a, b), Pair(a, c)) {
  Functor(fmap: fn(f: fn(b) -> c) -> fn(Pair(a, b)) -> Pair(a, c) {
    fn(p) {
      let Pair(x, y) = p
      Pair(x, f(y))
    }
  })
}

/// Phantom type for `Either Functor`.
pub type EitherF(a)

/// `Either Functor`.
/// ### Examples
/// ```gleam
/// either_functor().fmap(bool.negate)(Left(27))
/// // -> Left(27)
/// either_functor().fmap(bool.negate)(Right(False))
/// // -> Right(True)
/// ```
pub fn either_functor() -> Functor(EitherF(a), b, c, Either(a, b), Either(a, c)) {
  Functor(fmap: fn(f: fn(b) -> c) -> fn(Either(a, b)) -> Either(a, c) {
    fn(e) {
      case e {
        Left(x) -> Left(x)
        Right(y) -> Right(f(y))
      }
    }
  })
}

/// Phantom type for `Triple Functor`.
pub type TripleF(a, b)

/// `Triple Functor`.
/// ### Examples
/// ```gleam
/// triple_functor().fmap(bool.negate)(#("abc", 9, False))
/// // -> #("abc", 9, True)
/// ```
pub fn triple_functor() -> Functor(TripleF(a, b), c, d, #(a, b, c), #(a, b, d)) {
  Functor(fmap: fn(f: fn(c) -> d) -> fn(#(a, b, c)) -> #(a, b, d) {
    fn(p: #(a, b, c)) { #(p.0, p.1, f(p.2)) }
  })
}

/// Phantom type for `Writer Functor`.
pub type WriterF

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
pub fn writer_functor() -> Functor(
  WriterF,
  a,
  b,
  monad.Writer(a),
  monad.Writer(b),
) {
  Functor(fmap: fn(f: fn(a) -> b) {
    monad.fish(cat.id, cat.compose(monad.writer_return, f))
  })
}

/// Phantom type for `Reader Functor`.
pub type ReaderF(r)

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
pub fn reader_functor() -> Functor(
  ReaderF(r),
  a,
  b,
  monad.Reader(r, a),
  monad.Reader(r, b),
) {
  Functor(fmap: fn(f: fn(a) -> b) {
    fn(ra: monad.Reader(r, a)) -> monad.Reader(r, b) {
      let monad.Reader(g) = ra
      monad.Reader(cat.compose(f, g))
    }
  })
}

/// Phantom type for `Function Functor`.
pub type FunctionF(r)

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
