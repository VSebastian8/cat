import cat.{Identity, Reader, State, Writer}
import cat/instances/monad.{
  function_monad, identity_monad, list_monad, option_monad, reader_monad,
  result_monad, state_monad, writer_monad,
}
import gleam/int
import gleam/option.{None, Some}
import gleeunit/should

// Testing the identity monad instance.
pub fn identity_monad_test() {
  {
    use x <- identity_monad().bind(Identity("res: "))
    use y <- identity_monad().bind(Identity(7))
    identity_monad().return(x <> int.to_string(y))
  }
  |> should.equal(Identity("res: 7"))

  identity_monad().bind(Identity("res: "), fn(x) {
    identity_monad().bind(Identity(7), fn(y) {
      identity_monad().return(x <> int.to_string(y))
    })
  })
  |> should.equal(Identity("res: 7"))
}

// Testing the option monad instance.
pub fn option_monad_test() {
  let op = option_monad()
  {
    use x <- op.bind(Some(2))
    use y <- op.map(Some(3))
    x + y
  }
  |> should.equal(Some(5))
  {
    use x <- op.bind(None)
    use y <- op.map(Some(3))
    x + y
  }
  |> should.equal(None)
  {
    use x <- op.bind(Some(2))
    use y <- op.map(None)
    x + y
  }
  |> should.equal(None)
}

// Testing the list monad instance.
pub fn list_monad_test() {
  let lm = list_monad()
  {
    use x <- lm.bind([1, 2, 3])
    use y <- lm.bind([4, 5])
    lm.return(x * y)
  }
  |> should.equal([4, 5, 8, 10, 12, 15])
}

// Testing the result monad instance.
pub fn result_monad_test() {
  let rm = result_monad()
  {
    use x <- rm.bind(Ok(2))
    use y <- rm.map(Ok(3))
    x + y
  }
  |> should.equal(Ok(5))
  {
    use x <- rm.bind(Error("Nan"))
    use y <- rm.map(Ok(3))
    x + y
  }
  |> should.equal(Error("Nan"))
  {
    use x <- rm.bind(Ok(2))
    use y <- rm.map(Error("Nan"))
    x + y
  }
  |> should.equal(Error("Nan"))
}

// Testing the writer monad instance.
pub fn writer_monad_test() {
  {
    use x <- writer_monad().bind(Writer(2, "two + "))
    use y <- writer_monad().map(Writer(3, "three"))
    x + y
  }
  |> should.equal(Writer(5, "two + three"))
}

// Testing the reader monad instance.
pub fn reader_monad_test() {
  let r = {
    use t1 <- reader_monad().bind(Reader(fn(x) { x % 2 == 0 }))
    use t2 <- reader_monad().map(Reader(fn(x) { x % 3 == 0 }))
    t1 || t2
  }
  r.apply(5)
  |> should.equal(False)
  r.apply(6)
  |> should.equal(True)
}

// Testing the function monad instance.
pub fn function_monad_test() {
  let h = {
    use f <- function_monad().bind(fn(x) { fn(y) { x * y } })
    use x <- function_monad().map(fn(x) { x + 5 })
    f(x)
  }
  h(2)
  |> should.equal(14)
}

// Testing the state monad instance.
pub fn state_monad_test() {
  let count = State(fn(x) { #(x, x + 1) })
  {
    use x <- state_monad().bind(count)
    // 1
    use y <- state_monad().bind(count)
    // 2
    use z <- state_monad().map(count)
    // 3
    x + y + z
    // 1 + 2 + 3
  }.run(1)
  |> should.equal(#(6, 4))
}
