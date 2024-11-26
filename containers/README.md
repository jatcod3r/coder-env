# Coder Demonstration Environment

This repository deploys a simple Kubernetes environment to AWS, Azure, and GCP and demonstrates how to launch a Coder server within some cluster.

To facilitate deployments, Terraform will be used to manage, compose, validate, and deploy the entire Kubernetes infrastructure and supplementary Kubernetes applications (e.g. helmcharts, manifests, etc.)

# Getting Started

The kubernetes infrastructure and applications will be separate deployments. As highlighted on the [Terraform Github](https://github.com/hashicorp/terraform/issues/30340#issuecomment-1010202582), we should have 2 differing state files, managing their own resource statuses due to dependency issues that can arise.

## Creating Infrastructure

To start deploying, you'll need to run the Terraform CLI from one of the project directores, and populate inputs for the build to use:
```bash
$ terraform -chdir=./coderd validate
$ terraform -chdir=./coderd apply
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

- `/coderd`
- `/provisionerd`
- `/dockerd`
- `/database`

## Tasks

### Major

- [ ] None


### Minor

- [ ] None