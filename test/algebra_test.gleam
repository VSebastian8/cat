//// Test module for cat/algebra.gleam

import cat.{Const, Identity, Just, Left, Nothing, Pair, Right}
import cat/algebra as alg
import gleam/bool
import gleam/int
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

/// Testing the isomorphisms: zeta, eta, and theta.
pub fn exponentials_basic_test() {
  alg.zeta(cat.absurd)
  |> should.equal(Nil)

  alg.zeta_inv(Nil)
  |> should.equal(cat.absurd)

  alg.eta(cat.unit)
  |> should.equal(Nil)

  alg.eta_inv(Nil)
  |> should.equal(cat.unit)

  alg.theta(fn(_) { 42 })
  |> should.equal(42)

  alg.theta_inv(42)(Nil)
  |> should.equal(42)
}

/// Testing the isomorphisms: epsilon, upsilon, and omicron.
pub fn exponentials_properties_test() {
  let p1 =
    alg.epsilon(fn(e) {
      case e {
        Left(x) -> int.to_string(x)
        Right(y) -> bool.to_string(y)
      }
    })
  p1.fst(42)
  |> should.equal("42")
  p1.snd(True)
  |> should.equal("True")

  let f1 = alg.epsilon_inv(Pair(int.to_string, bool.to_string))
  f1(Left(42))
  |> should.equal("42")
  f1(Right(True))
  |> should.equal("True")

  let p2 = alg.upsilon(fn(x) { Pair(x * 2, x % 2 == 0) })
  p2.fst(4)
  |> should.equal(8)
  p2.snd(4)
  |> should.equal(True)

  let f2 = alg.upsilon_inv(Pair(fn(x) { x * 2 }, fn(x) { x % 2 == 0 }))
  f2(4)
  |> should.equal(Pair(8, True))

  let f3 = alg.omicron(fn(x) { fn(y) { x + y } })
  f3(Pair(3, 4))
  |> should.equal(7)

  let f4 = alg.omicron_inv(fn(p) { p.fst + p.snd })
  f4(1)(2)
  |> should.equal(3)
}
