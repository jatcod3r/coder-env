# Coder Demonstration Environment

This repository deploys an example Coder application onto AWS, Azure, and GCP using K8s, Container Orchestration, and Virtual Machines.

The following tools are used:
- Terraform (to manage, compose, validate, and deploy infrastructure)
- Coder CLI
- Helmcharts w/ Kustomize (to deploy to K8s)

# Getting Started

Each infrastructure and app will be deployed separately. As highlighted on the [Terraform Github](https://github.com/hashicorp/terraform/issues/30340#issuecomment-1010202582), we should have multiple state files, managing their own resource statuses due to dependency issues that can arise.

## Creating Infrastructure

To start deploying, you'll need to run the Terraform CLI from one of the project directores, and populate inputs for the build to use:
```bash
$ terraform -chdir=./k8s/src validate
$ terraform -chdir=./k8s/src apply
```

## Upload & Deploy Coder Templates

```bash
$ coder login --url <coder-svc-url>
$ coder templates push \
    -d ./examples/<template-dir> <template-name> \
    --variables-file ./inputs/examples/<template-input>.yaml
```

# Folder Layout

All projects will be deployed separately, but each one will have some reference to one another. So far, the following projects in this repository are:

```
/k8s
    /src
        /infrastructure
            /modules/aws
                /cluster
                /network
                /database
                /servers
        /coder
        /manifest
            /coder
            /default
            /kube-system
/vm
    /src
        /coder
            /main.tf
        /infrastructure/aws
            /coderd
            /network
            /provisionerd
            /dockerd
            /database
    /main.tf
```

## Tasks

### Major

- [ ] Create GCP examples
- [ ] Create Azure examples
- [ ] Integrate CI/CD pipeline for Coder workspace templates


### Minor

- [ ] None