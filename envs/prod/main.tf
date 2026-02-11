module "network" {
  source      = "../../modules/network"
  project_id  = var.project_id
  environment = var.environment
  region      = var.region
  subnet_cidr = var.subnet_cidr
}

module "compute" {
  source       = "../../modules/compute"
  project_id   = var.project_id
  environment  = var.environment
  region       = var.region
  zone         = var.zone
  machine_type = var.machine_type
  subnetwork   = module.network.subnet_id

  labels = {
    environment = var.environment
    application = "sandbox-app"
    owner       = "greg"
    managed_by  = "terraform"
    sandbox     = "true"
  }
}


