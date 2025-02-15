//// Test module for cat/algebra.gleam

import cat.{Const, Identity, Just, Left, Nothing, Pair, Right}
import cat/algebra as alg
import gleeunit/should

// Testing the isomorphisms: swap and switch.
pub fn commutativity_test() {
  alg.swap(Pair(2, "ab"))
  |> should.equal(Pair("ab", 2))

  alg.switch(Left("ab"))
  |> should.equal(Right("ab"))

  alg.switch(Right(True))
  |> should.equal(Left(True))
}

// Testing the isomorphisms: alpha and beta.
pub fn associativity_test() {
  alg.alpha(Pair(7, Pair(False, "a")))
  |> should.equal(Pair(Pair(7, False), "a"))

  alg.alpha_inv(Pair(Pair(7, False), "a"))
  |> should.equal(Pair(7, Pair(False, "a")))

  alg.beta(Left(7))
  |> should.equal(Left(Left(7)))

  alg.beta(Right(Left(False)))
  |> should.equal(Left(Right(False)))

  alg.beta(Right(Right("abc")))
  |> should.equal(Right("abc"))

  alg.beta_inv(Left(Left(7)))
  |> should.equal(Left(7))
}

/// Testing the isomorphism: product_to_sum, sum_to_product.
pub fn distributivity_test() {
  alg.product_to_sum(Pair(3, Left([1, 2, 3])))
  |> should.equal(Left(Pair(3, [1, 2, 3])))

  alg.product_to_sum(Pair(3, Right(True)))
  |> should.equal(Right(Pair(3, True)))

  alg.sum_to_product(Left(Pair(1, 2)))
  |> should.equal(Pair(1, Left(2)))

  alg.sum_to_product(Right(Pair(1, 3)))
  |> should.equal(Pair(1, Right(3)))
}

/// Testing the isomorphisms: rho, psi, omega, and delta.
pub fn equations_test() {
  alg.rho(Pair(2, Nil))
  |> should.equal(2)

  alg.rho_inv(2)
  |> should.equal(Pair(2, Nil))

  alg.psi(Left("a"))
  |> should.equal("a")

  alg.psi_inv(True)
  |> should.equal(Left(True))

  alg.omega(Nothing)
  |> should.equal(Left(Nil))

  alg.omega(Just(6))
  |> should.equal(Right(6))

  alg.omega_inv(Left(Nil))
  |> should.equal(Nothing)

  alg.omega_inv(Right(6))
  |> should.equal(Just(6))

  alg.delta(Left(5))
  |> should.equal(Pair(False, 5))

  alg.delta(Right(5))
  |> should.equal(Pair(True, 5))

  alg.delta_inv(Pair(False, [1, 2]))
  |> should.equal(Left([1, 2]))

  alg.delta_inv(Pair(True, [1, 2]))
  |> should.equal(Right([1, 2]))
}

/// Testing the gamma isomorphism.
pub fn maybe_adt_test() {
  Nothing
  |> alg.gamma
  |> should.equal(Left(Const(Nil)))

  Just(7)
  |> alg.gamma
  |> should.equal(Right(Identity(7)))

  Left(Const(Nil))
  |> alg.gamma_inv
  |> should.equal(Nothing)

  Right(Identity(2))
  |> alg.gamma_inv
  |> should.equal(Just(2))
}
