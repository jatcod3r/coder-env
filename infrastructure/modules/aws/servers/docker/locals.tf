locals {
    cloud-config = <<-END
        #cloud-config
        ${jsonencode({
            write_files = [
                {
                    path        = "/etc/docker/daemon.json"
                    permissions = "0644"
                    owner       = "root:root"
                    content     = file("${path.module}/../scripts/daemon.json")
                }
                # ,{
                #     path = "/etc/nginx/conf.d/default.conf"
                #     permissions = "0644"
                #     owner = "root:root"
                #     content = file("${path.module}/../scripts/default.conf")
                # }
            ]
        })}
    END
}