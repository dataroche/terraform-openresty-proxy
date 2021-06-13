locals {
  project_id     = "..."
  project_number = "..."
  region         = "us-central1"
  location       = "us-central"
}

module "proxy" {
  source = "./terraform-openresty-proxy"

  config = {
    project           = local.project_id
    project_number    = local.project_number
    location          = "US"
    region            = local.region
    base_image_name   = "openresty/openresty"
    base_image_tag    = "1.15.8.3-alpine"
    upstream_url      = "..."
    audience          = "..."
    authorized_domain = ""
    oauth_client_id   = "..."
    service_url       = "..."
  }
}