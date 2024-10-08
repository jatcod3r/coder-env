---
name: Node.js container and Open in Coder button
description: The goal is to show an Open in Coder button works in your repo to build a Kubernetes-managed container
tags: [kubernetes]
---

# Build a Kubernetes-managed Node.js container with an Open in Coder button

### Apps included

1. A web-based terminal
1. code-server IDE (VS Code in a browser)
1. VS Code Desktop icon

### Additional bash scripting

1. `git clone` the repo where Open in Coder button is clicked

### Node.JS version

Last updated at: 2023-12-30

Node.js `20.10.0`
npm `10.2.3`
yarn `1.22.19`

[Dockerfile](https://github.com/sharkymark/dockerfiles/blob/main/node/nodesource-method/Dockerfile)
[Container image](https://hub.docker.com/repository/docker/marktmilligan/node/tags)


### GitHub OAuth Admin Setup

1. Create an OAuth app in GitHub with correct URL and Callback URLs to your Coder deployment

2. K8s `values.yaml` example

```sh
# enable OAuth git authentication for git actions
    - name: CODER_EXTERNAL_AUTH_0_ID
      value: "primary-github"

    - name: CODER_EXTERNAL_AUTH_0_TYPE
      value: "github"

    - name: CODER_EXTERNAL_AUTH_0_CLIENT_ID
      value: "ed21c3********3bec7f"

    - name: CODER_EXTERNAL_AUTH_0_CLIENT_SECRET
      value: "299417626a5d48*******ba6dea0868c356e"
```

3. `systemd` example

```sh
CODER_EXTERNAL_AUTH_0_ID="primary-github"
CODER_EXTERNAL_AUTH_0_TYPE=github
CODER_EXTERNAL_AUTH_0_CLIENT_ID=b9684*********a7d03
CODER_EXTERNAL_AUTH_0_CLIENT_SECRET=4b00110dda08f8************c0385df092faec6b4
```

### GitHub OAuth Template Sections

1. Parameter to receive repo from user input at workspace creation

```hcl
data "coder_parameter" "git_repo_url" {
  name        = "Git report URL"
  description = "The `https` URL to your git repo - using your GitHub OAuth token"
  type        = "string"
  default     = "https://github.com/coder/coder-react"
  mutable     = true
  icon        = "https://git-scm.com/images/logos/downloads/Git-Icon-1788C.png"
}
```

2. Coder provider git auth data source

> `id` was configured in the Coder Admin setup

```hcl
data "coder_external_auth" "github" {
  # Matches the ID of the git auth provider in Coder.
  id = "primary-github"
}
```

3. `coder_agent` environment variable setting and `git clone` in `startup_script`

```hcl
resource "coder_agent" "dev" {...

  env = {
    GITHUB_TOKEN : data.coder_external_auth.github.access_token
  }

  startup_script  = <<EOT
#!/bin/sh

# clone repo
if test -z "${data.coder_parameter.git_repo_url.value}" 
then
  echo "No git repo specified, skipping"
else
  if [ ! -d "${local.folder_name}" ] 
  then
    echo "Cloning git repo..."
    git clone ${data.coder_parameter.git_repo_url.value}
  fi
  cd ${local.folder_name}
fi
```

### Repo Additions

Create markdown with your Coder Access URL (your deployment) and any parameters you want pre-populated. e.g., repo URL

```sh
[![Open in Coder](https://YOUR_ACCESS_URL/open-in-coder.svg)](https://YOUR_ACCESS_URL/templates/YOUR_TEMPLATE/workspace?param.Git%20Repo%20URL=https://github.com/coder/coder-react)
```

### Resources

[Coder provider Git Auth docs](https://registry.terraform.io/providers/coder/coder/latest/docs/data-sources/git_auth)

[Coder docs on Open in Coder](https://coder.com/docs/v2/latest/templates/open-in-coder)

[Coder docs to configure Git Auth](https://coder.com/docs/v2/latest/admin/external-auth)

[GitHub docs for creating an OAuth app](https://docs.github.com/en/apps/oauth-apps/building-oauth-apps/creating-an-oauth-app)

[Terraform kubernetes_pod provider](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/pod)
