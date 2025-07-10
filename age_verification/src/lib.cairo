#[starknet::interface]
pub trait IAgeVerifier<T> {
    fn verify_age_zk(self: @T, commitment: felt252, zk_proof: Array<felt252>) -> bool;
    fn set_min_age(ref self: T, new_min_age: u256);
    fn get_min_age(self: @T) -> u256;
}

#[starknet::contract]
mod AgeVerifier {
    use starknet::storage::{StoragePointerReadAccess, StoragePointerWriteAccess};
    use starknet::{ContractAddress, get_caller_address};

    // 아래 verifier 모듈은 age_prover.cairo 회로를 기반으로 컴파일해서 생성한 모듈이라고 가정
    use verifier_module; // ⚠️ 이 모듈은 별도로 생성되어야 함

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
        /// zk-STARK proof 기반으로 나이 증명을 검증
        fn verify_age_zk(
            self: @ContractState,
            commitment: felt252,
            zk_proof: Array<felt252>
        ) -> bool {
            let min_age = self.min_age.read();

            // zk-verifier 호출: 이 모듈은 off-chain에서 컴파일된 회로에서 생성돼야 함
            let is_valid = verifier_module::verify(
                public_inputs = [commitment, min_age.low].span(), // min_age는 u256이므로 low만 전달 (felt252만 가능)
                proof = zk_proof
            );

            assert(is_valid == true, 'Invalid zk-proof');
            return true;
        }

        fn set_min_age(ref self: ContractState, new_min_age: u256) {
            let caller = get_caller_address();
            let owner = self.owner.read();
            assert(caller == owner, 'Only owner can set min_age');
            self.min_age.write(new_min_age);
        }

        fn get_min_age(self: @ContractState) -> u256 {
            self.min_age.read()
        }
    }
}