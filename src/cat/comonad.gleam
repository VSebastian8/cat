//// Comonad type {minimal implementations - `extract` and `duplicate`/`extend`}

import cat/functor.{type Functor, Functor}

/// `Comonad` type.
/// ```
/// class Functor w => Comonad w where
/// ```
/// From this type you can construct a Functor instance containing a useful `map` function. Also, `extend` and `duplicate` can be expressed in terms of each other:
/// ```
/// extend f  = fmap f . duplicate
/// duplicate = extend id
/// fmap f    = extend (f . extract)
/// ```
pub type Comonad(w, a, b, wa, wb, wwa) {
  Comonad(
    extract: fn(wa) -> a,
    duplicate: fn(wa) -> wwa,
    extend: fn(fn(wa) -> b, wa) -> wb,
  )
}

// Functor instance from Comonad.
pub fn to_functor(
  w: Comonad(f, a, b, wa, wb, wwa),
) -> Functor(f, a, b, wa, wb) {
  Functor(fmap: fn(f) { fn(wx) { w.extend(fn(wy) { f(w.extract(wy)) }, wx) } })
}
