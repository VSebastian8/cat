//// Test module for cat/contravariant.gleam

import cat
import cat/contravariant.{
  type Contravariant, Contravariant, phantom, replace, replace_flip,
}
import cat/functor as fun
import cat/instances/contravariant as con
import gleam/int
import gleeunit/should

pub fn op_contravariant_test() {
  let original = con.Op(fn(x) { int.to_string(x * 2) })
  let f = fn(b) {
    case b {
      True -> 2
      False -> 4
    }
  }

  let result = con.op_contravariant().contramap(f)(original)

  result.apply(False)
  |> should.equal("8")
}

pub fn operators_test() {
  let o = con.Op(int.to_string)
  // Doesn't matter what value/type we use for the final apply  
  True
  |> replace(con.op_contravariant())(7, o).apply
  |> should.equal("7")

  [1, 2, 3]
  |> replace_flip(con.op_contravariant())(o, 7).apply
  |> should.equal("7")
}

pub type UnitF

pub fn phantom_test() {
  let unit_functor: fun.Functor(UnitF, _, _, _, Nil) =
    fun.Functor(fmap: fn(_) { cat.unit })
  let unit_contravariant: Contravariant(UnitF, _, _, Nil, _) =
    Contravariant(contramap: fn(_) { cat.unit })

  "abc"
  |> phantom(unit_functor, unit_contravariant)
  |> should.equal(Nil)
}
