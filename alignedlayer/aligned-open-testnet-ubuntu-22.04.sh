#!/bin/bash

# Install Aligned CLI
curl -L https://raw.githubusercontent.com/yetanotherco/aligned_layer/main/batcher/aligned/install_aligned.sh | bash

# Download the proof test files
curl -L https://raw.githubusercontent.com/yetanotherco/aligned_layer/main/batcher/aligned/get_proof_test_files.sh | bash

# Clear any existing verification data
rm -rf ~/aligned_verification_data/

# Submit the proof using the aligned binary from the specific path
/root/.aligned/bin/aligned submit \
  --proving_system SP1 \
  --proof ~/.aligned/test_files/sp1_fibonacci.proof \
  --vm_program ~/.aligned/test_files/sp1_fibonacci-elf \
  --aligned_verification_data_path ~/aligned_verification_data \
  --conn wss://batcher.alignedlayer.com

# Verify the proof on-chain using the aligned binary from the specific path
/root/.aligned/bin/aligned verify-proof-onchain \
  --aligned-verification-data ~/aligned_verification_data/*.json \
  --rpc https://ethereum-holesky-rpc.publicnode.com \
  --chain holesky
