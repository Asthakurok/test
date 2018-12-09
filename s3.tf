resource "aws_s3_bucket" "terraform-state" {
    bucket = "databasemigrationskillnet"
    acl = "private"

    tags {
        Name = "Terraform state"
    }
}
