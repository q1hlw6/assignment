output "kubernetes_endpoint" {
  value = data.aws_eks_cluster.cluster.endpoint
}

output "kubernetes_certificate_authority_data" {
  value = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
}
