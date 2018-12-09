resource "aws_eks_cluster" "hbi-microservice-cluster" {
  name     = "${var.cluster-name}"
  role_arn = "${aws_iam_role.hbi-microservice-cluster.arn}"

  vpc_config {
    security_group_ids = ["${aws_security_group.hbi-microservice-cluster.id}"]
    subnet_ids         = ["${module.vpc.public_subnets}"]
  }

  depends_on = [
    "aws_iam_role_policy_attachment.hbi-microservice-cluster-AmazonEKSClusterPolicy",
    "aws_iam_role_policy_attachment.hbi-microservice-cluster-AmazonEKSServicePolicy",
  ]
}
