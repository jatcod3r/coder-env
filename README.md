# Coder Demonstration Environment
This repository deploys a simple Kubernetes environment to AWS, Azure, and GCP and demonstrates how to launch a Coder server within some cluster.

To facilitate deployments, Terraform will be used to manage, compose, validate, and deploy the entire Kubernetes infrastructure and supplementary Kubernetes applications (e.g. helmcharts, manifests, etc.)

# Getting Started

The kubernetes infrastructure and applications will be separate deployments. As highlighted on the [Terraform Github](https://github.com/hashicorp/terraform/issues/30340#issuecomment-1010202582), we should have 2 differing state files, managing their own resource statuses due to dependency issues that can arise.

## Creating Infrastructure
To start deploying, you'll need to run the Terraform CLI from `/infrastructure` and populate inputs for the build to use:
```bash
$ terraform -chdir=./infrastructure validate
$ terraform -chdir=./infrastructure apply -var-file='../inputs/infrastructure.tfvars'
```

As for how an example of how the base inputs should look like, here's a sample `.tfvars`:
```conf
region = "ca-central-1"
cluster_name = "coder-eks"
vpc_name = "coder-vpc"
ami_id = "ami-009749b44be7aa9fa" # amazon/amazon-eks-node-1.30-v20240807
cluster_api_version = "client.authentication.k8s.io/v1beta1"
cluster_version = "1.30"
sysbox_install_label = {
    "beta.kubernetes.io/os" = "linux"
}
instance_type = "t3.large"
```

## Creating Coder Servers & Kubernetes Apps

```bash
$ terraform -chdir=./apps validate
$ terraform -chdir=./apps apply -var-file='../inputs/apps.tfvars'
```

## Upload & Deploy Coder Templates
```bash
$ coder login --url <coder-svc-url>
$ coder templates push \
    -d ./examples/<template-dir> <template-name> \
    --variables-file ./inputs/examples/<template-input>.yaml
```


# Folder Layout
The `/infrastructure` folder acts as the main entry point of the terraform deployment and is responsibel for creating the kubernetes foundation (compute, roles, loadbalancers, etc.) Resources specific to a cloud provider will be located in `/infrastructure/modules`.

Applications that will be deployed are stored in `/apps`, and this will also contain the coder deployment which is in `/apps/coder`. Every subfolder in `/apps` references a namespace that will be deployed. For example, the coder server will be spawned underneath the **coder** namespace.



## Tasks

### Major
- [ ] Troubleshoot connectivity issues between Coder Server and Coder Agents (i.e. why cant I see workspace statuses nor connect to them)
- [ ] Migrate Kubernetes postgresql DB to AWS
- [ ] Create counterparts for GCP and Azure

### Minor
- [ ] Maybe use [data.local_sensitive_file](https://registry.terraform.io/providers/hashicorp/local/latest/docs/data-sources/sensitive_file) to dynamically retreive inputs?
- [ ] Setup private jumpbox to run EKS workloads
- [ ] Make Cluster completely private, only exposing the Coder server
- [ ] Setup custom domain name for accessing Coder
- [ ] Setup CA and SSL for custom domain
