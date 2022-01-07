# Lesson 04 - Building an Ansible sandbox

Use Terraform to stand up an environment to use Ansible from and on. The Ansible control node, which is where
Ansible runs from, needs to be a Linux system with Python 3.8+ installed. There will be 3 target systems we will
configure using Ansible, and they will have there web server ports exposed to the public internet, but will otherwise
only be accessible from the control node and other targets.

## Using the Terraform code

The variables that need to be populated are listed in the documentation at the bottom of this file.
This documentation is generated from the Terraform code itself using
[terraform-docs](https://github.com/terraform-docs/terraform-docs).

```console
$ terraform-docs markdown table --output-file README.md --output-mode inject .
README.md updated successfully
```

## Create the environment

Create `terraform.tfvars`:

```terraform
aws_region       = "us-east-2"
owner_email      = "eugene.gotimer@steampunk.com"
key_name         = "gene-test-us-east-2"
private_key_file = "/mnt/c/Users/GotimerEugene/.ssh/gene-test-us-east-2.pem"
```

Then we can use Terraform to create the environment. The `remote_exec` provisioner will
make it take longer that we've seen.

```console
$ terraform init
...
$ terraform apply
...
Outputs:

target_instance_ids = [
  "i-063e6e1b8ac71119d",
  "i-035125762cbce935d",
  "i-00fbe57ff4efea08a",
]
target_private_ips = [
  "10.8.0.188",
  "10.8.0.209",
  "10.8.0.206",
]
target_public_ips = [
  "18.117.70.148",
  "52.15.172.210",
  "18.116.43.247",
]
workstation_instance_id = "i-02890a16937a7af84"
workstation_private_ip = "10.8.0.26"
workstation_public_ip = "3.142.171.59"
```

## Retrieving output values

We'll need to use these output values in this and later lessons. If the values scroll
off the screen, we can use `terraform output` to extract them from the state
file again. That means we have to run the commands in this directory so Terraform finds
the right state, or we'll have to use the `-state=path` option to point to the
correct `terraform.tfstate` file.

```console
$ terraform output
target_instance_ids = [
  "i-063e6e1b8ac71119d",
  "i-035125762cbce935d",
  "i-00fbe57ff4efea08a",
]
target_private_ips = [
  "10.8.0.188",
  "10.8.0.209",
  "10.8.0.206",
]
target_public_ips = [
  "18.117.70.148",
  "52.15.172.210",
  "18.116.43.247",
]
workstation_instance_id = "i-02890a16937a7af84"
workstation_private_ip = "10.8.0.26"
workstation_public_ip = "3.142.171.59"
$ terraform output target_private_ips
[
  "10.8.0.188",
  "10.8.0.209",
  "10.8.0.206",
]
$ terraform output workstation_public_ip
"3.142.171.59"
```

## Connect to the workstation

SSH into the Ansible workstation using the `workstation_public_ip` and the key file you
specified. The username is `ubuntu`.

```console
$ ssh -i /mnt/c/Users/GotimerEugene/.ssh/gene-test-us-east-2.pem ubuntu@3.142.171.59
The authenticity of host '3.142.171.59 (3.142.171.59)' can't be established.
ED25519 key fingerprint is SHA256:s14sJUQRjUGCD5/9SE9SeVcfsV0f3qDocxrwrSPSMbM.
This key is not known by any other names
Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
Warning: Permanently added '3.142.171.59' (ED25519) to the list of known hosts.
Welcome to Ubuntu 20.04.3 LTS (GNU/Linux 5.11.0-1023-aws x86_64)
...
ubuntu@ip-10-8-0-26:~$
```

## Verify Ansible is installed

On the Ansible workstation, we'll run our first Ansible command to verify it
is installed correctly.

```console
ubuntu@ip-10-8-0-26:~$ ansible localhost -m ping
[WARNING]: No inventory was parsed, only implicit localhost is available
localhost | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
```

If we get a `pong` back from our `ping`, then Ansible was able to log onto
the target (`localhost` in this case) and run a command.

## Leave the environment running

We'll leave the environment running for now since we'll be using it for the
upcoming lessons. We can destroy it later (and recreate it if we need to).

## Why not local Ansible

It might be easier in a lot of ways if we used our laptop as our Ansible control node
instead of creating a workstation in AWS and working remotely.
But there are reasons we aren't doing that. Some of them are:

1. Installing the correct version of Python is generally easy only if another version of Python isn't already installed.
1. Set up and configuration on different OSes and platforms sometimes has subtle or non-subtle differences.
1. Use of the command line (e.g., escaping special characters) differs between shells.
1. It is safer to work in a sandbox as closed off from the public internet as possible.
1. Using a system near the target network as a bastion host or workstation is not an uncommon pattern.
1. SSH tunneling can be non-trivial to set up and troubleshoot, especially on multiple platforms and SSH clients.
1. We aren't using this environment for an extended period.

So in the interest of simplifying the workshop, I chose to use a remote
control node. It just makes for a smoother, more homogeneous workshop experience.

That said, we could do the rest of the exercises with some changes to the security groups on the targets,
eliminating the workstation, and making sure Ansible is installed and configured correctly on our laptop.
If you choose to go that route, caveat lector. The necessary changes are left as an exercise for the reader.

## End of Lesson 04

# Terraform documentation

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.11 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 3.65 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 3.70.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_default_security_group.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/default_security_group) | resource |
| [aws_instance.target](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance) | resource |
| [aws_instance.workstation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance) | resource |
| [aws_internet_gateway.sandbox_gateway](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/internet_gateway) | resource |
| [aws_route_table.rtb_public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
| [aws_route_table_association.rta_subnet_public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_security_group.target_sg](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group.workstation_sg](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group_rule.target_sg_allow_all_outgoing](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.target_sg_allow_internal_mongodb](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.target_sg_allow_public_http](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.target_sg_allow_public_https](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.target_sg_allow_workstation_ssh](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_subnet.public_subnet](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_vpc.sandbox_vpc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc) | resource |
| [aws_ami.ubuntu_linux](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_profile"></a> [aws\_profile](#input\_aws\_profile) | Local AWS profile to use for AWS credentials | `string` | `"default"` | no |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS region to build in | `string` | n/a | yes |
| <a name="input_key_name"></a> [key\_name](#input\_key\_name) | Name of an already-installed AWS keypair | `string` | n/a | yes |
| <a name="input_owner_email"></a> [owner\_email](#input\_owner\_email) | Email address to tag resources with | `string` | n/a | yes |
| <a name="input_private_key_file"></a> [private\_key\_file](#input\_private\_key\_file) | Path to the private key of the already-installed AWS keypair | `string` | n/a | yes |
| <a name="input_project_tag"></a> [project\_tag](#input\_project\_tag) | Project name to tag resources with for grouping | `string` | `"IntroToTerraformAndAnsible"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_target_instance_ids"></a> [target\_instance\_ids](#output\_target\_instance\_ids) | IDs of the Ansible target instances |
| <a name="output_target_private_ips"></a> [target\_private\_ips](#output\_target\_private\_ips) | Private IP addresses of the Ansible targets |
| <a name="output_target_public_ips"></a> [target\_public\_ips](#output\_target\_public\_ips) | Public IP addresses of the Ansible targets |
| <a name="output_workstation_instance_id"></a> [workstation\_instance\_id](#output\_workstation\_instance\_id) | ID of the Ansible workstation instance |
| <a name="output_workstation_private_ip"></a> [workstation\_private\_ip](#output\_workstation\_private\_ip) | Private IP address of the Ansible workstation |
| <a name="output_workstation_public_ip"></a> [workstation\_public\_ip](#output\_workstation\_public\_ip) | Public IP address of the Ansible workstation |
<!-- END_TF_DOCS -->
