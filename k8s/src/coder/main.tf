provider "coderd" {
    url = var.coder_primary_url
    token = var.coder_session_token
}

data "coderd_organization" "default" {
    is_default = true
}