// Phantom type for `Identity Functor`.
pub type IdentityF

/// Phantom type for `Const Functor`. \
/// We bind the first parameter of Const.
pub type ConstF(c)

/// Phantom type for `Option Functor`.
pub type OptionF

/// Phantom type for `List Functor`.
pub type ListF

/// Phantom type for `Pair Functor`.
pub type PairF(a)

/// Phantom type for `Either Functor`.
pub type EitherF(a)

/// Phantom type for `Tuple Functor`.
pub type TupleF(a)

/// Phantom type for `Triple Functor`.
pub type TripleF(a, b)

/// Phantom type for `Writer Functor`.
pub type WriterF

/// Phantom type for `Reader Functor`.
pub type ReaderF(r)

/// Phantom type for `Function Functor`.
pub type FunctionF(r)

/// Bifunctor composition type. 
/// ```
/// newtype BiComp bf fu gu a b = BiComp (bf (fu a ) (gu b))
/// ```
pub type BiComp(bf, fu, gu, a, b, fua, gub, bifgab) {
  // fua = fu(a)
  // gub = gu(b)
  // bifgab = bf(fua, gub)
  BiComp(bifgab)
}

/// Phantom type for `Tuple Bifunctor`.
pub type TupleBF

/// Phantom type for `Pair Bifunctor`.
pub type PairBF

/// Phantom type for `Either Bifunctor`.
pub type EitherBF

/// Phantom type for bifunctor composition.
pub type BiCompF(bf, fu, gu)

/// Phantom type for `Op Contravariant`.
pub type OpC(r)

/// Phantom type for the `function profunctor`.
pub type ArrowPro
