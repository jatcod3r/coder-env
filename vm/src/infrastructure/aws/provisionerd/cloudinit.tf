data "cloudinit_config" "cloudinit" {
    gzip = false
    base64_encode = false

    part {
        filename = "01-setup"
        content_type = "text/cloud-config"
        content = templatefile("${path.module}/scripts/cloud-config.yaml.tftpl", {
            CODER_CACHE_DIRECTORY = var.cache_dir
            CODER_ENV_CONFIG_FILE = var.env_config_file
        })
    }

    part {
        filename = "02-install"
        content_type = "text/x-shellscript"
        content = templatefile("${path.module}/scripts/install.sh.tftpl", {
            TF_VER = "1.9.2"
            CODER_URL = var.coder_url
            CODER_CACHE_DIRECTORY = var.cache_dir
            CODER_ENV_CONFIG_FILE = var.env_config_file
            CODER_PROVISIONER_DAEMON_KEY = var.provisionerd_key
        })
    }
}