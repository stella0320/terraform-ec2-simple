output "ec2_public_ip" {
  value = module.ec2.ec2_public_ip
}

output "ssh_command" {
  value = module.ec2.ssh_command
}