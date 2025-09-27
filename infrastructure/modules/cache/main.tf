resource "aws_elasticache_cluster" "main" {
  cluster_id           = var.name
  engine              = "redis"
  node_type           = "cache.t3.micro"
  num_cache_nodes     = 1
  parameter_group_name = "default.redis6.x"
  port                = 6379
}

resource "aws_security_group" "redis" {
  name_prefix = "${var.name}-redis-sg"
  description = "Security group for Redis cluster"

  ingress {
    from_port   = 6379
    to_port     = 6379
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
