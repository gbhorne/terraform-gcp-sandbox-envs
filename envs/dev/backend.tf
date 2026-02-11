terraform {
  backend "gcs" {
    bucket = "playground-s-11-3d8045b7"
    prefix = "terraform/state/dev"
  }
}
