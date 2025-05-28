 backend "s3" {
    bucket = "remote_state"
    key    = "terraform.tfstate"
    region = "eu-north-1"
}
