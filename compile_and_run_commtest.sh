#!/bin/bash

# Get ip1 ip1_internal ip2 ip2_internal keyfile by sourcing set_ips_and_keyfile.sh
. set_ips_and_keyfile.sh || exit 1

username=ubuntu

# Remove any previously existing commtest.c file on ip1 host
ssh -i $keyfile $username@$ip1 "rm -f commtest.c"

# Copy commtest.c to ip1 host and then compile it
scp -i $keyfile ../benchmark-codes/communication_test/commtest.c $username@$ip1: || exit 1
ssh -i $keyfile $username@$ip1 "rm -f a.out && mpicc -O3 commtest.c && ls -lrt" || exit 1

# Copy executable a.out to ip2 host
scp -i $keyfile $username@$ip1:a.out . || exit 1
scp -i $keyfile a.out $username@$ip2: || exit 1
rm a.out || exit 1

echo "Running a.out (commtest.c) with mpirun now..."
ssh -i $keyfile $username@$ip1 "time mpirun -np 2 -host $ip1_internal,$ip2_internal ./a.out 1000 1 10" || exit 1

echo "Running a.out (commtest.c) with mpirun now..."
ssh -i $keyfile $username@$ip1 "time mpirun -np 2 -host $ip1_internal,$ip2_internal ./a.out 10 20000000 1" || exit 1

echo ; echo compile_and_run_commtest.sh done.
