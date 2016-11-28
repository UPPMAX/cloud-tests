#!/bin/bash

# Get ip1 ip1_internal ip2 ip2_internal keyfile by sourcing set_ips_and_keyfile.sh
. set_ips_and_keyfile.sh || exit 1

username=ubuntu

# Remove any previously existing stdout.txt output.txt files on ip1 host
ssh -i $keyfile $username@$ip1 "rm -f stdout.txt output.txt"

echo "Running test_matrix_manager with mpirun now..."
ssh -i $keyfile $username@$ip1 "time mpirun -np 1 -host $ip1_internal,$ip2_internal,$ip1_internal,$ip2_internal ./test_matrix_manager 2000 2 > stdout.txt" || exit 1

# Copy result files
scp -i $keyfile $username@$ip1:stdout.txt . || exit 1
scp -i $keyfile $username@$ip1:output.txt . || exit 1

echo ; echo run_mmul.sh done.
