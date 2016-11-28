#!/bin/bash

if [ "$#" -ne 4 ]; then
    echo "Please give 4 arguments: N nWorkers nThreads cacheInGB"
    echo where
    echo "N         = matrix dimension, should be 1000, 2000, 4000, 8000, 16000 etc"
    echo "nWorkers  = number of worker processes"
    echo "nThreads  = number of worker threads used by each worker process"
    echo "cacheInGB = chunk cache size in GB (negative value means cache disabled)"
    exit 1;
fi

N=$1
echo N is $N
nWorkers=$2
echo nWorkers is $nWorkers
nThreads=$3
echo nThreads is $nThreads
cacheInGB=$4
echo cacheInGB is $cacheInGB

# Get ip1 ip1_internal ip2 ip2_internal keyfile by sourcing set_ips_and_keyfile.sh
. set_ips_and_keyfile.sh || exit 1

username=ubuntu

# Remove any previously existing stdout.txt output.txt files on ip1 host
ssh -i $keyfile $username@$ip1 "rm -f stdout.txt output.txt"

echo "Running test_matrix_manager with mpirun now..."
ssh -i $keyfile $username@$ip1 "mpirun --bind-to none -np 1 -host $ip1_internal,$ip2_internal,$ip1_internal,$ip2_internal ./test_matrix_manager $N $nWorkers $nThreads $cacheInGB > stdout.txt" || exit 1

# Copy result files
scp -i $keyfile $username@$ip1:stdout.txt . || exit 1
scp -i $keyfile $username@$ip1:output.txt . || exit 1

echo stdout.txt: ; cat stdout.txt
grep uteMo output.txt | grep Mul | grep took

echo ; echo run_mmul.sh done.
