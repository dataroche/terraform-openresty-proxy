


# Mirror base image from Dockerhub image into Google Container Registry
module "docker-mirror" {
  source      = "./docker-mirror"
  image_name  = var.config.base_image_name
  image_tag   = var.config.base_image_tag
  dest_prefix = "gcr.io/${var.config.project}"
}

# Hydrate docker template file into .build directory
resource "local_file" "dockerfile" {
  depends_on = [template_dir.swiss]
  content = templatefile("${path.module}/Dockerfile.template", {
    project = var.config.project
    image   = var.config.base_image_name
    tag     = var.config.base_image_tag
  })
  filename = "${path.module}/.build/Dockerfile"
}

# Build a customized image
resource "null_resource" "openresty_image" {
  depends_on = [module.docker-mirror]
  triggers = {
    # Rebuild if we change the base image, dockerfile, or bpm-platform config
    image = "gcr.io/${var.config.project}/openresty:${var.config.base_image_tag}_${
      sha1(
        "${sha1(local_file.dockerfile.content)}${sha1(local_file.config.content)}${sha1(local_file.login.content)}${data.archive_file.swiss.output_sha}"
      )
    }"
  }
  provisioner "local-exec" {
    command = <<-EOT
        gcloud builds submit \
        --project ${var.config.project} \
        --tag ${self.triggers.image} \
        ${path.module}/.build
    EOT
  }
}
