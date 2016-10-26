#!/bin/bash

if [ "$#" -ne 5 ]; then
    echo "Please give 5 arguments: ip1 ip1_internal ip2 ip2_internal keyfile"
    exit 1;
fi

# ip1 and ip2 below are the "Floating IPs" of the two instances
ip1=$1
ip1_internal=$2
ip2=$3
ip2_internal=$4
keyfile=$5

username=ubuntu

# Copy testprog.c to ip1 host and then compile it
scp -i $keyfile testprog.c $username@$ip1:
ssh -i $keyfile $username@$ip1 "mpicc testprog.c && ls -lrt"

# Copy executable a.out to ip2 host
scp -i $keyfile $username@$ip1:a.out .
scp -i $keyfile a.out $username@$ip2:
rm a.out

echo "Running a.out (from testprog.c) with mpirun now..."
ssh -i $keyfile $username@$ip1 "mpirun -np 2 -host $ip1_internal,$ip2_internal ./a.out"
