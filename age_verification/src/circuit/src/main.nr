// src/main.nr
use std::hash::poseidon2::Poseidon2::hash;

fn main(age: Field, nonce: Field, commitment: pub Field, min_age: pub Field) {
    let recomputed_commitment: Field = compute_commitment(age, nonce);
    assert(recomputed_commitment == commitment, "Invalid commitment");

    assert(age as u32 >= min_age as u32, "Age is below the minimum age");
}

fn compute_commitment(age: Field, nonce: Field) -> Field {
    let inputs: [Field; 2] = [age, nonce];

    let commitment: Field = hash(inputs, 2);

    commitment
}

#[test]
fn test_compute_commitment() {
    let age: Field = 21;
    let nonce: Field = 1;

    let commitment: Field = compute_commitment(age, nonce);
    println(commitment);
}
