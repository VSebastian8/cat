import category_theory/monad.{Writer, fish, return}
import gleam/io
import gleam/string
import gleeunit/should

pub fn writer_test() {
  io.debug("Testing the writer type")

  let up_case = fn(s: String) { Writer(string.uppercase(s), "upCase ") }
  let to_words = fn(s: String) { Writer(string.split(s, " "), "toWords ") }
  let process = fish(up_case, to_words)

  process("Anna has apples")
  |> should.equal(Writer(["ANNA", "HAS", "APPLES"], "upCase toWords "))

  return(27)
  |> should.equal(Writer(27, ""))
}
