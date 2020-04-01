#install ansible
sudo apt-add-repository ppa:ansible/ansible

sudo apt-get update

sudo apt-get install ansible -y

#install terraform
sudo apt-get install wget unzip -y

sudo wget https://releases.hashicorp.com/terraform/0.12.24/terraform_0.12.24_linux_amd64.zip

sudo unzip terraform_0.12.24_linux_amd64.zip -d /usr/local/bin

#install azure cli
sudo apt-get install ca-certificates curl apt-transport-https lsb-release gnupg\

curl -sL https://packages.microsoft.com/keys/microsoft.asc |
    gpg --dearmor |
    sudo tee /etc/apt/trusted.gpg.d/microsoft.asc.gpg > /dev/null

AZ_REPO=$(lsb_release -cs)
echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ $AZ_REPO main" |
    sudo tee /etc/apt/sources.list.d/azure-cli.list

sudo apt-get update

sudo apt-get install azure-cli

sudo apt-get install python-pip

sudo pip install azure

#set exe permissions
chmod +x ~/TheQuest/start.sh
chmod +x ~/TheQuest/teardown.sh

#all that's left is to set the env variables at /etc/environment
#and to go to /etc/ansible/ansbile.cfg and uncomment the line that says "host_key_checking = False"
#also restart the session
