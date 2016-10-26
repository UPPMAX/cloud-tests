# cloud-tests

Repository intended for test scripts and similar things related to
performance tests and other kinds of tests of cloud systems, e.g. Smog
at UPPMAX.

Created by Elias Rudberg in October 2016.

To use these scripts, do as follows:

(1) Edit set_ips_and_keyfile.sh to add the IP addresses of the
instances you want to use, and the path to the keyfile needed to
access those instances.

(2) Run ./prepare_instances.sh

(3) Now you can run ./compile_and_run_testprog.sh and/or
./compile_and_run_commtest.sh and/or other similar things.
