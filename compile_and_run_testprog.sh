#!/bin/bash

# Get ip1 ip1_internal ip2 ip2_internal keyfile by sourcing set_ips_and_keyfile.sh
. set_ips_and_keyfile.sh || exit 1

username=ubuntu

# Remove any previously existing testprog.c file on ip1 host
ssh -i $keyfile $username@$ip1 "rm -f testprog.c" || exit 1

# Copy testprog.c to ip1 host and then compile it
scp -i $keyfile testprog.c $username@$ip1: || exit 1
ssh -i $keyfile $username@$ip1 "mpicc testprog.c && ls -lrt" || exit 1

# Copy executable a.out to ip2 host
scp -i $keyfile $username@$ip1:a.out . || exit 1
scp -i $keyfile a.out $username@$ip2: || exit 1
rm a.out || exit 1

echo "Running a.out (from testprog.c) with mpirun now..."
ssh -i $keyfile $username@$ip1 "mpirun -np 2 -host $ip1_internal,$ip2_internal ./a.out" || exit 1

echo ; echo compile_and_run_testprog.sh done.
