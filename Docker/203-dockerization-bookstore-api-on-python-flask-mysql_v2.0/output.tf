output "webserver-dns" {
  value = "http://${aws_instance.webserver.public_dns}"
}

output "ssh-command" {
  value = "ssh -i ${var.key-name}.pem ec2-user@${aws_instance.webserver.public_ip}"
}