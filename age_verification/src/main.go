package main

import (
	"context"
	"encoding/json"
	"fmt"
	"log"
	"math/big"
	"os"

	"github.com/NethermindEth/starknet.go/rpc"
	"github.com/NethermindEth/starknet.go/utils"
)

func main() {
	// 1. proof.json 불러오기
	proofBytes, err := os.ReadFile("../target/execute/age_verification/execution2/proof/proof.json")
	if err != nil {
		log.Fatal(err)
	}

	// 2. JSON 파싱
	var proofData struct {
		Proof []string `json:"proof"`
	}
	if err := json.Unmarshal(proofBytes, &proofData); err != nil {
		log.Fatal(err)
	}

	// 3. proof 값들 → []*felt.Felt로 변환
	zkProof := make([]*felt.Felt, len(proofData.Proof))
	for i, hexStr := range proofData.Proof {
		val, ok := new(big.Int).SetString(hexStr[2:], 16)
		if !ok {
			log.Fatalf("Invalid proof value: %s", hexStr)
		}
		zkProof[i] = new(felt.Felt).SetBigInt(val)
	}

	// 4. RPC client 설정
	rpcUrl := "http://127.0.0.1:5050" // 또는 Infura, Nethermind testnet RPC
	client, err := rpc.NewClient(rpcUrl)
	if err != nil {
		log.Fatal(err)
	}
	provider := rpc.NewProvider(client)

	// 5. 주소 및 엔트리포인트 설정
	contractAddress, _ := utils.HexToFelt("0x124aeb495b947201f5fac96fd1138e326ad86195b98df6dec9009158a533b49")
	entryPointSelector, _ := utils.HexToFelt("0x123456789abcdef123456789abcdef123456789abcdef123456789abcdef1234")
	nonce := new(felt.Felt).SetUint64(0)

	// 6. public input: commitment, min_age
	rawCommitment := "3440838995217384099100790940376406314506664941916081612275129365527562547805"
	commitmentInt, _ := new(big.Int).SetString(rawCommitment, 10)
	commitment := new(felt.Felt).SetBigInt(commitmentInt)
	minAge := new(felt.Felt).SetUint64(19)

	// 7. calldata: [commitment, min_age, ...zk_proof]
	calldata := []*felt.Felt{commitment, minAge}
	calldata = append(calldata, zkProof...)

	// 8. invoke 트랜잭션 생성
	tx := rpc.InvokeTxnV1{
		Type:               rpc.TransactionType_Invoke,
		Version:            rpc.TransactionV1,
		Nonce:              nonce,
		MaxFee:             new(felt.Felt).SetUint64(1000000),
		Signature:          []*felt.Felt{}, // AA 아니면 비워도 됨
		ContractAddress:    contractAddress,
		EntryPointSelector: entryPointSelector,
		Calldata:           calldata,
	}

	// 9. 트랜잭션 전송
	result, err := provider.AddInvokeTransaction(context.Background(), tx)
	if err != nil {
		log.Fatal("invoke tx failed:", err)
	}

	fmt.Println("✅ Transaction Hash:", result.TransactionHash.String())
}
