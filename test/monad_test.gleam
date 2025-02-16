//// Test module for cat/monad.gleam

import cat/monad.{Reader, Writer, fish, reader_return, writer_return}
import gleam/string
import gleeunit/should

/// Testing the writer type, fish function (composition) and return (identity).
pub fn writer_test() {
  let up_case = fn(s: String) { Writer(string.uppercase(s), "upCase ") }
  let to_words = fn(s: String) { Writer(string.split(s, " "), "toWords ") }
  let process = fish(up_case, to_words)

  process("Anna has apples")
  |> should.equal(Writer(["ANNA", "HAS", "APPLES"], "upCase toWords "))

  writer_return(27)
  |> should.equal(Writer(27, ""))
}

/// Testing the reader type.
pub fn reader_test() {
  let r = Reader(fn(x) { x % 2 == 1 })
  r.apply(6)
  |> should.equal(False)

  let f = fn(x) { x * 3 }
  reader_return(f)
  |> should.equal(Reader(f))
}
