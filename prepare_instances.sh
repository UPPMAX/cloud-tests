# The following seems to work for the Ubuntu-16.04 image on Smog

# ip1 and ip2 below are the "Floating IPs" of the two instances
# (replace "x.x.x.x" by the actual IP addresses to use)
ip1=x.x.x.x
ip1_internal=x.x.x.x
ip2=x.x.x.x
ip2_internal=x.x.x.x

# Replace "x.pem" here by actual key file needed to access the instances
keyfile=x.pem

# Username to use to login to instances
username=ubuntu

# Start by logging in with -o StrictHostKeyChecking=no to avoid having to interactively answer "yes" at first login.
ssh -o StrictHostKeyChecking=no -i $keyfile $username@$ip1 hostname
ssh -o StrictHostKeyChecking=no -i $keyfile $username@$ip2 hostname

# Login again and run the hostname command on each instance, just to verify that it is working
ssh -i $keyfile $username@$ip1 hostname
ssh -i $keyfile $username@$ip2 hostname

# Update and install needed packages on each host
for currip in $ip1 $ip2 ; do
    echo currip is now $currip
    ssh -i $keyfile $username@$currip sudo apt-get -y update
    ssh -i $keyfile $username@$currip sudo apt-get -y upgrade
    ssh -i $keyfile $username@$currip sudo apt-get -y dist-upgrade
    ssh -i $keyfile $username@$currip sudo apt install -y openmpi-bin libopenmpi-dev
done

# Create new ssh key files without passphrase
rm id_rsa id_rsa.pub
ssh-keygen -N "" -f id_rsa -t rsa

# Copy id_rsa key file to .ssh directory of ip1 host
scp -i $keyfile id_rsa $username@$ip1:.ssh/

# Add id_rsa.pub to .ssh/authorized_keys file on ip2 host
scp -i $keyfile id_rsa.pub $username@$ip2:
ssh -i $keyfile $username@$ip2 "cat id_rsa.pub >> .ssh/authorized_keys"
rm id_rsa id_rsa.pub

# Do a ssh login from ip1 to ip2
ssh -i $keyfile $username@$ip1 "ssh -o StrictHostKeyChecking=no $ip2_internal hostname"

echo Testing mpirun for hostname now...
ssh -i $keyfile $username@$ip1 "mpirun -np 2 -host $ip1_internal,$ip2_internal hostname"

echo Checking gcc version and ompi_info now...
ssh -i $keyfile $username@$ip1 "gcc --version && ompi_info | head -n 22"

# Run some tests
./compile_and_run_testprog.sh $ip1 $ip1_internal $ip2 $ip2_internal $keyfile
#./compile_and_run_commtest.sh $ip1 $ip1_internal $ip2 $ip2_internal $keyfile

echo Done!
