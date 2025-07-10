// zk-STARK 회로: 사용자가 자신의 age와 nonce를 알고 있으며,
// 그것이 주어진 commitment와 일치하고,
// 동시에 age >= min_age를 만족한다는 것을 증명함

use core::poseidon::poseidon_hash_span;
use core::integer::u256_divmod;

/// Main zk-proof circuit entry point
/// private inputs (witness):
///   - age: 사용자의 실제 나이
///   - nonce: 솔트 값
///
/// public inputs:
///   - commitment: poseidon(age, nonce)
///   - min_age: 허용된 최소 나이
fn main(
    age: felt252, 
    nonce: felt252, 
    commitment: felt252, 
    min_age: felt252
) {
    // ---------------------------
    // [1] Poseidon 커밋먼트 검증
    // ---------------------------
    // 사용자 입력 (age, nonce)로 다시 해시하여 commitment를 재계산
    let input_values = [age, nonce];
    let recomputed_commitment = poseidon_hash_span(input_values.span());

    // 조건 1: recomputed_commitment == supplied commitment
    assert(recomputed_commitment == commitment, 'Invalid commitment: poseidon(age, nonce) mismatch');

    // ---------------------------
    // [2] 나이 조건 검증
    // ---------------------------
    // 조건 2: age ≥ min_age
    assert(age >= min_age, 'Invalid: age is less than minimum allowed');
}