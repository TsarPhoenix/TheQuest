die(){ #create function to kill script
  echo >&2 "$@"
  exit 1
} 

#kill script if no args
[ "$#" -ge 1 ] || die "1 arguement required, $# provided"

#set args into "string" variable
str="'$*'"

#output versions
ansible --version
terraform --version

#important variables!
quest_directory=./
ansible_directory=./ansible/
terraform_directory=./terraform/
vm_pass=GrainTheftVisit9!
ansible_vault_path=./ansible/ansible-vault.txt
group_vars_all_file=./ansible/group_vars/all.yml
group_vars_ubuntu_file=./ansible/group_vars/tag_os_ubuntu.yml
inventory_file=./ansible/azure_rm.yml
playbook_file=./ansible/playbook-theQuest.yml
ansible_vault_password=TheQuest2

#terraform init for first run
cd ${terraform_directory}
terraform init
cd ..

#create vault-password-file using a reasonible password
echo ${ansible_vault_password} >> ${ansible_vault_path}

#pass important variables into ansible
ansible-vault encrypt_string --vault-id ${ansible_vault_path} ${vm_pass} --name 'ansible_password' | tee ${group_vars_ubuntu_file} ${group_vars_all_file}
echo "quest_directory:" ${quest_directory} >> ${group_vars_all_file}
echo "ansible_directory:" ${ansible_directory} >> ${group_vars_all_file}
echo "terraform_directory:" ${terraform_directory} >> ${group_vars_all_file}


#run ansible playbook w/ vault password, dynamic inventory and our output statement as a variable.
ansible-playbook ${playbook_file} -i ${inventory_file} --vault-id ${ansible_vault_path} --extra-vars "node_args=${str}"
cd ${quest_directory}

#cleanup
  #remove old var files
  rm ${group_vars_ubuntu_file}
  rm ${group_vars_all_file}
