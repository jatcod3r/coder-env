data "cloudinit_config" "cloudinit" {
    gzip = false
    base64_encode = false
    part {
        filename = "01-setup"
        content_type = "text/cloud-config"
        content = templatefile("${path.module}/scripts/cloud-config.yaml.tftpl", {
            CODER_ENV = indent(4, trim(templatefile("${path.module}/scripts/coder.env.tftpl", {
                ENV = var.coder_env.CODERD != {} ? var.coder_env.CODERD : { CODER_NULL = ""}
            }), "\n"))
            CODER_WS_PROXY_ENV = indent(4, trim(templatefile("${path.module}/scripts/coder.env.tftpl", {
                ENV = var.coder_env.WS_PROXY != {} ? var.coder_env.WS_PROXY : { CODER_NULL = ""}
            }), "\n"))
            CODER_TLS_CRT = indent(4, templatefile("${path.module}/secrets/tls.crt", {}))
            CODER_TLS_KEY = indent(4, templatefile("${path.module}/secrets/tls.key", {}))
        })
    }
    part {
        filename = "02-install"
        content_type = "text/x-shellscript"
        content = templatefile("${path.module}/scripts/install.sh.tftpl", {
            ENABLE_AS_PROXY = var.coder_env.WS_PROXY != {} ? "enable" : ""
            TF_VER = "1.9.2"
            CODER_VER = "2.17.2"
        })
    }
}