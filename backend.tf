terraform {
backend "s3" {
    bucket = "rebelgrease-state"
    key    = "terraform.tfstate"
    region = "eu-north-1"
    dynamodb_table = "tf_lockid"
}
}
