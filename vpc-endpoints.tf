#####################################################
# Creates Gateway Endpoint for AWS DynamoDB Service #
#####################################################

data "aws_vpc_endpoint_service" "dynamodb" {
  service      = "dynamodb"
  service_type = "Gateway"
}

resource "aws_vpc_endpoint" "dynamodb" {
  service_name    = data.aws_vpc_endpoint_service.dynamodb.service_name
  route_table_ids = [aws_default_route_table.main.id]
  vpc_id          = aws_vpc.main.id

  lifecycle {
    ignore_changes = [
      route_table_ids
    ]
  }

  tags = {
    Name = "${var.network_tags_name}-dynamodb"
  }
}

########################################################################
# Creates Gateway Endpoint for AWS Simple Storage Service (S3) Service #
########################################################################

data "aws_vpc_endpoint_service" "s3" {
  service      = "s3"
  service_type = "Gateway"
}

resource "aws_vpc_endpoint" "s3" {
  service_name    = data.aws_vpc_endpoint_service.s3.service_name
  route_table_ids = [aws_default_route_table.main.id]
  vpc_id          = aws_vpc.main.id

  lifecycle {
    ignore_changes = [
      route_table_ids
    ]
  }

  tags = {
    Name = "${var.network_tags_name}-s3"
  }
}
