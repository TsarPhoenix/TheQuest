Quick note: When I have a project of some kind, personal or professional there's a few things I want written down so that anyone who sees it later will know whatI knew when writting it. 
            The main parts of this are the Endstate or Goal, and the Tools used to get to the end state. Optionally if there's a given why I will add the why.
            This doc also helps me when I get stuck on the what do I need to be doing to get back to the right state of mind.

Goal: Completely from scratch in Azure, use Terraform and Ansible to create a node.js server exposed on a public IP that will return "echoing {statement}" where {statement} is passed in at creation time.
Acceptance Criteria:
  - Process should be kicked off by running ./start.sh and everything that was created should be destroyed by running ./teardown.sh
  - If {statement} is "hello", hitting [https://%7bpublic_ip%7d/echo]https://{public_ip}/echo should return "echoing hello"
  - All resources should be contained within a resource group in Azure

Tools:
  Ansible *
  Terraform *
  NodeJS
  Forever
  .sh
  ssh (to get into ubuntu machine used to run everything)
  Azure
  
  Ansible and Terraform are required on the server the sh scripts are run on.

Why: To get an idea for the types of issues involved with a project that would involve the various tools used here.

Setup:
  #pull repo in
  git clone https://github.com/TsarPhoenix/TheQuest.git  {enter credentials}

  chmod +x vmSetup.sh

  run ./vmSetup.sh and accept the prompts

  #set environment variables
  sudo vim /etc/environment

  {add environment variables}
  {set the same env variables for Azure credentials for ansible}

  Finally go to /etc/ansible/ansible.cfg and uncomment the line that says "Host_key_checking = False"
  You will need 8 enviornment variables setup to be able to connect and create the azure resources required for this project. These are the values for your service principles.
  I will not be providing these because they are currently tied to my personal azure account.
    TF_VAR_client_id
    TF_VAR_client_secret
    TF_VAR_subscription_id
    TF_VAR_tenant_id
    AZURE_CLIENT_ID
    AZURE_SECRET
    AZURE_SUBSCRIPTION_ID
    AZURE_TENANT
    
    logout and log back in to have the env vars be picked up

Script Descriptions:
  start.sh
    Usage:
      ./start.sh <arg1, arg2... argn>
    Explaination:
      start.sh requires at least 1 argument to run, and will exit with code 1 if no arg is provided. 
      All args will be combined into a single string to be outputed by the nodejs script when the correct public ip is hit.
      The script sets some locations as hardcoded locations. This is less that ideal, and a 2.0 version of the script would begin making these variables dynamic rather than hardcoded.
  teardown.sh
    Usage:
      ./teardown.sh
    Explaination:
      This script calls an ansible playbook to run a terraform destroy on the same resources created by the start.sh script. This effectivly neutralizes everything the start.sh script creates.
  vmSetup.sh
    Usage:
      ./vmSetup.sh
    Explaination:
      Runs simple install commands and gives execution permissions on the other scripts mentioned above.

Misc:
  Terraform:
    Love this tool. From the organization on how it works, to how it intelligently (for the most part) is able to figure out dependencies on the fly. 
    Becuase it's interacting with an API to create resources it's very terse about the syntax. But that just means we can be more precise in what we're telling Terraform to do with the Azure api. 
    If I was to complain about something to do with terraform. It'd be the weird state it's in version-wise. I used terraform 0.12.24, but did most of my learning on v0.11.x. This caused some confusion in syntax, but nothing too complicated. 
    So the weirdest part of using Terraform for this project was trying to dynamically get information to ansible after it was done. There were some ways I came up with to get this done, but the easiest was to run terraform as part of the ansible script. 
  Ansible:
    I like this tool too, but not quite as much. I hade more trouble figuring out parts of this tool.
    I split my ansible playbook into 3 different plays. 
      1. Run terraform
      2. Install required software on the remote server
      3. copy the nodejs files to the remote server and start the app. 
    These three plays were chosen mostly because they seemd like logical seperations
    One of the more difficult parts of this setting up the ansible playbook was dealing with credentials to get onto the remote server.
    I learned a lot about ansible-vault and how to pass values that are encrypted by ansible-vault into and then be read by the ansible play.
    Currently the .sh script has a password in plaintext and hardcoded that is very inscure. 
    A 2.0 version of this script would have ansible read in the password from the terraform script and encrypt and use those credentials for ssh. 
    Another weird thing was figuring out how to set up a dynamic inventory based on the resources in azure. Luckily there's a built in azure_rm plugin that makes it fairly trivial to create.
    Did have to spend some time to learn how to interact with that kind of inventory, and to create groups within a dynamic inventory. 
  2.0 wishlist:
    Remove all hardcoded valuse from start.sh in favor of dynamically set values. start.sh currently requires the file layout to look the same every time.
    Pull ssh credentials from terraform rahter than having to pass credentials insecurely
