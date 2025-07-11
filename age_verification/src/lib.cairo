use core::poseidon::poseidon_hash_span;

#[executable]
fn main(
    age: felt252,
    nonce: felt252,
    commitment: felt252,
    min_age: felt252
) {
    // 🔐 [1] Poseidon 해시로 commitment 다시 계산
    let input_vals = [age, nonce];
    let recomputed_commitment = poseidon_hash_span(input_vals.span());

    // 🔍 [2] 커밋먼트 값 비교
    assert(recomputed_commitment == commitment, 'Invalid commitment');

    let age_u256: u256 = age.into();
    let min_age_u256: u256 = min_age.into();

    // 🔍 [3] 최소 나이 조건 검증
    assert(age_u256 >= min_age_u256, 'Invalid age');
}