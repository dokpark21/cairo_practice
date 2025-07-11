use core::poseidon::poseidon_hash_span;

fn age_verification(
    age: felt252,
    nonce: felt252,
    commitment: felt252,
    min_age: felt252,
) -> bool {
    let input_vals = [age, nonce];
    let recomputed_commitment = poseidon_hash_span(input_vals.span());
    assert(recomputed_commitment == commitment, 'Invalid commitment');

    let age_u32: u32 = age.try_into().expect('Invalid age');
    let min_age_u32: u32 = min_age.try_into().expect('Invalid min_age');

    assert(age_u32 >= min_age_u32, 'Age is below the minimum age');

    // scarb prove가 회로가 너무 작아서 range check layout을 충족 못하는 문제를 해결하기 위한 더미 계산
    let mut acc: u64 = 0;
    let mut i: u32 = 0;
    loop {
        if i == 50 {
            break;
        };
        let i_u64: u64 = i.into();
        acc = acc + (i_u64 * i_u64);
        i = i + 1;
    };

    // acc는 사용하지 않아도 컴파일러가 제거하지 않도록 더미 비교
    assert(acc >= 0, 'Dummy calc');

    return true;
}

#[executable]
fn main(
    age: felt252,
    nonce: felt252,
    commitment: felt252,
    min_age: felt252,
) {
    let _ = age_verification(age, nonce, commitment, min_age);
}