use integrity::{
    StarkProofWithSerde, VerifierSettings, PoseidonImpl, StarkProof, ProofVerified
};
use starknet::storage::{StoragePointerReadAccess, StoragePointerWriteAccess};
use starknet::{ContractAddress};

#[storage]
struct Storage {
    owner: ContractAddress,
    composition_contract_address: ContractAddress,
    oods_contract_address: ContractAddress
}

fn verify_age_zk(
    self: @ContractState,
    commitment: felt252,
    min_age: felt252,
    zk_proof: Array<felt252>
) -> bool {
    // zk_proof 변환
    let stark_proof: StarkProof = StarkProofWithSerde { data: zk_proof }.into();

    // VerifierSettings 정의 (prover와 동일하게 구성)
    let settings = VerifierSettings {
        memory_verification: 0,  // strict 모드
        num_public_memory_pages: 0,
        ..VerifierSettings::default()
    };

    // zk-proof 검증
    let _security_bits = stark_proof.verify(
        self.composition_contract_address.read(),
        self.oods_contract_address.read(),
        @settings
    );

    // fact (이벤트 용) — 선택적
    let (program_hash, output_hash) = stark_proof.public_input.verify_strict();
    let fact = PoseidonImpl::new()
        .update(program_hash)
        .update(output_hash)
        .finalize();

    let event = ProofVerified {
        job_id: 0,
        fact,
        security_bits: _security_bits,
        settings
    };
    self.emit(event);

    return true;
}