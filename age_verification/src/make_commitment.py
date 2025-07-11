from typing import List

# 아래 함수들과 상수는 네가 준 코드에서 가져온 것
from poseidon_py.c_bindings import hades_permutation
from poseidon_py.utils import blockify

POSEIDON_PARAMS = {
    "m": 3,
    "r": 2,
}


def poseidon_perm(x: int, y: int, z: int) -> List[int]:
    return hades_permutation([x, y, z])


def poseidon_hash_many(array: List[int]) -> int:
    values = list(array)
    m = POSEIDON_PARAMS["m"]
    r = POSEIDON_PARAMS["r"]

    # Pad input with 1 followed by 0's (if necessary).
    values.append(1)
    values += [0] * (-len(values) % r)

    assert len(values) % r == 0
    state = [0] * m
    for block in blockify(data=values, chunk_size=r):
        state = list(
            hades_permutation(
                [state_val + block_val for state_val, block_val in zip(state, block)] + state[-1:]
            )
        )

    return state[0]


def make_commitment(age: int, nonce: int) -> int:
    """
    Poseidon 해시를 사용해 age와 nonce를 커밋먼트로 변환
    """
    return poseidon_hash_many([age, nonce])


if __name__ == "__main__":
    age = int(input("Enter your age: "))
    nonce = int(input("Enter a random nonce: "))

    commitment = make_commitment(age, nonce)
    print(f"Commitment (Poseidon): {commitment}")