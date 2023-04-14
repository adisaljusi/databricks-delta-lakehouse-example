locals {
  prefix       = "${var.workload}-${var.environment}-${var.region}"
  prefix_clean = "${var.workload}${var.environment}${var.region}"
}
