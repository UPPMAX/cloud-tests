# The following seems to work for the Ubuntu-16.04 image on Smog

# Get ip1 ip1_internal ip2 ip2_internal ip3 ip3_internal ip4 ip4_internal keyfile by sourcing set_ips_and_keyfile_4inst.sh
. set_ips_and_keyfile_4inst.sh || exit 1

# Username to use to login to instances
username=ubuntu

# Start by logging in with -o StrictHostKeyChecking=no to avoid having to interactively answer "yes" at first login.
for currip in $ip1 $ip2 $ip3 $ip4 ; do
    ssh -o StrictHostKeyChecking=no -i $keyfile $username@$currip hostname || exit 1
done

# Login again and run the hostname command on each instance, just to verify that it is working
for currip in $ip1 $ip2 $ip3 $ip4 ; do
    ssh -i $keyfile $username@$currip hostname
done

# Update and install needed packages on each host
for currip in $ip1 $ip2 $ip3 $ip4 ; do
    echo currip is now $currip
    ssh -i $keyfile $username@$currip sudo apt-get -y update
    ssh -i $keyfile $username@$currip sudo apt-get -y upgrade
    ssh -i $keyfile $username@$currip sudo apt-get -y dist-upgrade
    ssh -i $keyfile $username@$currip sudo apt install -y openmpi-bin libopenmpi-dev
done

# Create new ssh key files without passphrase
rm id_rsa id_rsa.pub
ssh-keygen -N "" -f id_rsa -t rsa

# Copy id_rsa key file to .ssh directory of each host
for currip in $ip1 $ip2 $ip3 $ip4 ; do
    scp -i $keyfile id_rsa $username@$currip:.ssh/
done

# Add id_rsa.pub to .ssh/authorized_keys file on ip1 ip2 ip3 ip4 hosts
for currip in $ip1 $ip2 $ip3 $ip4 ; do
    scp -i $keyfile id_rsa.pub $username@$currip:
    ssh -i $keyfile $username@$currip "cat id_rsa.pub >> .ssh/authorized_keys"
done
rm id_rsa id_rsa.pub

# Do a ssh login from each ip to each of the internal ips
for currip in $ip1 $ip2 $ip3 $ip4 ; do
    for currip_internal in $ip2_internal $ip3_internal $ip4_internal ; do
	ssh -i $keyfile $username@$currip "ssh -o StrictHostKeyChecking=no $currip_internal hostname"
    done
done

echo

echo Testing mpirun -np 4 for hostname now...
echo mpirun line looks like this: "mpirun -np 4 -host $ip1_internal,$ip2_internal,$ip3_internal,$ip4_internal hostname"
ssh -i $keyfile $username@$ip1 "mpirun -np 4 -host $ip1_internal,$ip2_internal,$ip3_internal,$ip4_internal hostname"

echo Checking gcc version and ompi_info now...
ssh -i $keyfile $username@$ip1 "gcc --version && ompi_info | head -n 22"

# Run some tests
./compile_and_run_testprog_4inst.sh

echo Done!
