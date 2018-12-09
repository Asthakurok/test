terraform {
    backend "S3" {
    bucket = "databasemigrationskillnet"
    key = "terraform/Statefile"
    }
}
