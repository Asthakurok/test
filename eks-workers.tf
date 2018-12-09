data "aws_ami" "hbi-microservice-cluster-node" {
  filter {
    name   = "name"
    values = ["amazon-eks-node-v*"]
  }

  most_recent = true
  owners      = ["602401143452"] # Amazon
}

# EKS currently documents this required userdata for EKS worker nodes to
# properly configure Kubernetes applications on the EC2 instance.
# We utilize a Terraform local here to simplify Base64 encoding this
# information into the AutoScaling Launch Configuration.
# More information: https://docs.aws.amazon.com/eks/latest/userguide/launch-workers.html

locals {
  Test-node-userdata = <<USERDATA
#!/bin/bash
set -o xtrace
/etc/eks/bootstrap.sh --apiserver-endpoint '${aws_eks_cluster.hbi-microservice-cluster.endpoint}' --b64-cluster-ca '${aws_eks_cluster.hbi-microservice-cluster.certificate_authority.0.data}' '${var.cluster-name}'
USERDATA
}

resource "aws_launch_configuration" "Test" {
  associate_public_ip_address = true
  iam_instance_profile        = "${aws_iam_instance_profile.hbi-microservice-cluster-node.name}"
  image_id                    = "${data.aws_ami.hbi-microservice-cluster-node.id}"
  instance_type               = "t2.micro"
  name_prefix                 = "terraform-eks-Test"
  security_groups             = ["${aws_security_group.hbi-microservice-cluster-node.id}"]
  user_data_base64            = "${base64encode(local.Test-node-userdata)}"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "Test" {
  desired_capacity     = 2
  launch_configuration = "${aws_launch_configuration.Test.id}"
  max_size             = 2
  min_size             = 1
  name                 = "terraform-eks-Test"
  vpc_zone_identifier  = ["${module.vpc.public_subnets}"]

  tag {
    key                 = "Name"
    value               = "terraform-eks-Test"
    propagate_at_launch = true
  }

  tag {
    key                 = "kubernetes.io/cluster/${var.cluster-name}"
    value               = "owned"
    propagate_at_launch = true
  }
}
