import cat.{Identity}
import cat/instances/monad.{identity_monad, list_monad, option_monad}
import gleam/int
import gleam/option.{None, Some}
import gleeunit/should

// Testing the identity monad instance.
pub fn identity_monad_test() {
  {
    use x <- identity_monad().bind(Identity("res: "))()
    use y <- identity_monad().bind(Identity(7))()
    identity_monad().return(x <> int.to_string(y))
  }
  |> should.equal(Identity("res: 7"))

  identity_monad().bind(Identity("res: "))(fn(x) {
    identity_monad().bind(Identity(7))(fn(y) {
      identity_monad().return(x <> int.to_string(y))
    })
  })
  |> should.equal(Identity("res: 7"))
}

// Testing the option monad instance.
pub fn option_monad_test() {
  let op = option_monad()
  {
    use x <- op.bind(Some(2))()
    use y <- op.bind(Some(3))()
    op.return(x + y)
  }
  |> should.equal(Some(5))
  {
    use x <- op.bind(None)()
    use y <- op.bind(Some(3))()
    op.return(x + y)
  }
  |> should.equal(None)
  {
    use x <- op.bind(Some(2))()
    use y <- op.bind(None)()
    op.return(x + y)
  }
  |> should.equal(None)
}

// Testing the list monad instance.
pub fn list_monad_test() {
  let lm = list_monad()
  {
    use x <- lm.bind([1, 2, 3])()
    use y <- lm.bind([4, 5])()
    lm.return(x * y)
  }
  |> should.equal([4, 5, 8, 10, 12, 15])
}
