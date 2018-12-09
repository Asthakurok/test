resource "aws_security_group" "hbi-microservice-cluster" {
  name        = "terraform-eks-hbi-microservice-cluster"
  description = "Cluster communication with worker nodes"
  vpc_id      = "${module.vpc.vpc_id}"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "hbi-microservice-cluster"
  }
}

resource "aws_security_group_rule" "hbi-microservice-cluster-ingress-node-https" {
  description              = "Allow pods to communicate with the cluster API Server"
  from_port                = 443
  protocol                 = "tcp"
  security_group_id        = "${aws_security_group.hbi-microservice-cluster.id}"
  source_security_group_id = "${aws_security_group.hbi-microservice-cluster-node.id}"
  to_port                  = 443
  type                     = "ingress"
}

resource "aws_security_group_rule" "hbi-microservice-cluster-ingress-workstation-https" {
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Allow workstation to communicate with the cluster API Server"
  from_port         = 443
  protocol          = "tcp"
  security_group_id = "${aws_security_group.hbi-microservice-cluster.id}"
  to_port           = 443
  type              = "ingress"
}
