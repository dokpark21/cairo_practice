#[starknet::interface]
pub trait IAgeVerifier<T> {
    fn verify_age(self: @T, commitment: felt252, age: felt252, nonce: felt252) -> bool;
    fn set_min_age(ref self: T, new_min_age: u256);
    fn get_min_age(self: @T) -> u256;
}

#[starknet::contract]
mod AgeVerifier {
    use starknet::storage::{StoragePointerReadAccess, StoragePointerWriteAccess};
    use core::poseidon::poseidon_hash_span;
    use starknet::{ContractAddress,get_caller_address};

    #[storage]
    struct Storage {
        min_age: u256,
        owner: ContractAddress
    }

    #[constructor]
    fn constructor(
        ref self: ContractState,
        _min_age: u256,
        _owner: ContractAddress
    ) {
        self.min_age.write(_min_age);
        self.owner.write(_owner);
    }

    #[abi(embed_v0)]
    impl AgeVerifierImpl of super::IAgeVerifier<ContractState> {
        fn verify_age(
            self: @ContractState,
            commitment: felt252,
            age: felt252,
            nonce: felt252
        ) -> bool {
            let recomputed_commitment = poseidon_hash_span([age, nonce].span());
            assert(commitment == recomputed_commitment, 'Invalid commitment');

            let min_age = self.min_age.read();
            let age_u256: u256 = age.try_into().unwrap();

            if age_u256 >= min_age {
                return true;
            } else {
                return false;
            }
        }

        fn set_min_age(ref self: ContractState, new_min_age: u256) {
            let caller = get_caller_address();
            let owner = self.owner.read();
            
            assert(caller==owner, 'Only owner can set min_age');

            self.min_age.write(new_min_age);
        }

        fn get_min_age(self: @ContractState) -> u256 {
            self.min_age.read()
        }
    }
}