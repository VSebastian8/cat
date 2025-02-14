import category_theory.{Just, Left, Nothing, Pair, Right}
import category_theory/isomorphisms as iso
import gleeunit/should

// Testing the isomorphisms: swap and switch.
pub fn commutativity_test() {
  iso.swap(Pair(2, "ab"))
  |> should.equal(Pair("ab", 2))

  iso.switch(Left("ab"))
  |> should.equal(Right("ab"))

  iso.switch(Right(True))
  |> should.equal(Left(True))
}

// Testing the isomorphisms: alpha and beta.
pub fn associativity_test() {
  iso.alpha(Pair(7, Pair(False, "a")))
  |> should.equal(Pair(Pair(7, False), "a"))

  iso.alpha_inv(Pair(Pair(7, False), "a"))
  |> should.equal(Pair(7, Pair(False, "a")))

  iso.beta(Left(7))
  |> should.equal(Left(Left(7)))

  iso.beta(Right(Left(False)))
  |> should.equal(Left(Right(False)))

  iso.beta(Right(Right("abc")))
  |> should.equal(Right("abc"))

  iso.beta_inv(Left(Left(7)))
  |> should.equal(Left(7))
}

/// Testing the isomorphism: product_to_sum, sum_to_product.
pub fn distributivity_test() {
  iso.product_to_sum(Pair(3, Left([1, 2, 3])))
  |> should.equal(Left(Pair(3, [1, 2, 3])))

  iso.product_to_sum(Pair(3, Right(True)))
  |> should.equal(Right(Pair(3, True)))

  iso.sum_to_product(Left(Pair(1, 2)))
  |> should.equal(Pair(1, Left(2)))

  iso.sum_to_product(Right(Pair(1, 3)))
  |> should.equal(Pair(1, Right(3)))
}

/// Testing the isomorphisms: rho, psi, omega, and delta.
pub fn equations_test() {
  iso.rho(Pair(2, Nil))
  |> should.equal(2)

  iso.rho_inv(2)
  |> should.equal(Pair(2, Nil))

  iso.psi(Left("a"))
  |> should.equal("a")

  iso.psi_inv(True)
  |> should.equal(Left(True))

  iso.omega(Nothing)
  |> should.equal(Left(Nil))

  iso.omega(Just(6))
  |> should.equal(Right(6))

  iso.omega_inv(Left(Nil))
  |> should.equal(Nothing)

  iso.omega_inv(Right(6))
  |> should.equal(Just(6))

  iso.delta(Left(5))
  |> should.equal(Pair(False, 5))

  iso.delta(Right(5))
  |> should.equal(Pair(True, 5))

  iso.delta_inv(Pair(False, [1, 2]))
  |> should.equal(Left([1, 2]))

  iso.delta_inv(Pair(True, [1, 2]))
  |> should.equal(Right([1, 2]))
}
