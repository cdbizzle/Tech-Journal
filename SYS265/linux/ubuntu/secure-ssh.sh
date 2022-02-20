#secure-ssh.sh
#author cole
#creates a new ssh user using $1 parameter
sudo adduser $1
sudo mkdir /home/$1/.ssh
#adds a public key from the local repo
sudo cp /home/cole/Tech-Journal/SYS265/linux/public-keys/id_rsa.pub /home/$1/.ssh/authorized_keys
sudo chmod 700 /home/$1/.ssh
sudo chmod 600 /home/$1/.ssh/authorized_keys
sudo chown -R $1:$1 /home/$1/.ssh
#removes roots ability to ssh in for CENTOS machines
sudo sed -i "s/#PermitRootLogin yes/PermitRootLogin no/g" /etc/ssh/sshd_config
