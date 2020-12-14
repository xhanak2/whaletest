### What is whaletest?
This project is just POC, what should demonstrate using Terraform and Ansible in Hetzner cloud. At the end we will have a basic http cluster of two nodes using Hetzner load balancer.

## Prerequisites
Prior is necessary to create API Token in Hetzner cloud. To create one, Sign in into the Hetzner Cloud Console choose a Project, go to Access → Tokens , and create a new token. Make sure to copy the token because it won't be shown to you again. (https://https://docs.hetzner.cloud/)
Is also necessary to add public SSH key what is "injected" to deployed servers and used by Ansible

We also expect that Terraform and Ansible has been installed already on machine you are using to run this POC.

## Content
```whaletest.tf``` is simple Terraform file which is performing following:
- configure Hetzner provider + API Token
- Create 2 servers ```Node1``` and ```Node2``` (Ubuntu 20.04 with flavour of "cx11" = 1vCPU,2GB RAM, 20GB storage)
- Private network, subnet and connect servers to this network
- Inventory file ```hosts``` what is used later as an inventory file in Ansible playbook

```play.yml``` is a very simple Ansible playbook used for main two steps
1. Install Docker on both nodes (it consists of adding Docker repo, install apt packages etc.). What should be configured is described here: (https://https://docs.docker.com/engine/install/ubuntu/)
2. Pull and run yeasy/simple-web container on both nodes. More (https://hub.docker.com/r/yeasy/simple-web/)

## How to run Terraform and Ansible
1. Download ```whaletest.tf``` and ```play.yml``` to a the same (new created) directory
2. Run ```terraform init```  (this will initialize Hetzner Cloud provider)
3. Run ```terraform apply``` (this will create all components in Hetzner Cloud and inventory file ```hosts```)
4. Run ```ansible-playbook play.yml -i hosts``` (this will configure both nodes as a part of cluster and run necessary containers)

## How to test?
In Hetzner cloud console find public IP of a cluster and just paste this IP to a webbrowser. In case that cluster is up&running a "Welcome screen" what is showing your IP is visible.

## What next and technical debt?
To extend this POC it should be necessary to improve security (as we are using "root" account) and make it fully automated using some (example Gitlab) pipeline. 
