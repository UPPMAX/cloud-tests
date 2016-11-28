#!/bin/bash

# Get ip1 ip1_internal ip2 ip2_internal keyfile by sourcing set_ips_and_keyfile.sh
. set_ips_and_keyfile.sh || exit 1

username=ubuntu

# Remove any previously existing test_matrix_manager cht_worker stdout.txt output.txt files on ip1 host
ssh -i $keyfile $username@$ip1 "rm -f test_matrix_manager cht_worker stdout.txt output.txt"

# Get code from github
ssh -i $keyfile $username@$ip1 "rm -rf git_tmp ; mkdir git_tmp ; cd git_tmp ; git clone https://github.com/UPPMAX/benchmark-codes.git" || exit 1

# Download and compile CHT-MPI library
ssh -i $keyfile $username@$ip1 "cd git_tmp/benchmark-codes/mpi_mmul_test ; ./prepare_cht_mpi.sh" || exit 1

# Download and compile OpenBLAS library
ssh -i $keyfile $username@$ip1 "cd git_tmp/benchmark-codes/mpi_mmul_test ; ./prepare_openblas.sh" || exit 1

# Compile and copy executable files to home directory on ip1 host
ssh -i $keyfile $username@$ip1 "cd git_tmp/benchmark-codes/mpi_mmul_test && make && cp test_matrix_manager cht_worker ~" || exit 1

# Copy executables to ip2 host
scp -i $keyfile $username@$ip1:test_matrix_manager . || exit 1
scp -i $keyfile $username@$ip1:cht_worker . || exit 1
scp -i $keyfile test_matrix_manager cht_worker $username@$ip2: || exit 1
rm test_matrix_manager cht_worker || exit 1

echo "Running test_matrix_manager with mpirun now..."
ssh -i $keyfile $username@$ip1 "time mpirun -np 1 -host $ip1_internal,$ip2_internal,$ip1_internal,$ip2_internal ./test_matrix_manager 2000 2 > stdout.txt" || exit 1

# Copy result files
scp -i $keyfile $username@$ip1:stdout.txt . || exit 1
scp -i $keyfile $username@$ip1:output.txt . || exit 1

echo ; echo compile_and_run_mmul.sh done.
