# Lesson 04 - An Ansible sandbox

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
  "i-035fb3e7070884f0f",
  "i-09fe5ddef8f69a2a6",
  "i-057cbce3baaac9ef2",
]
target_private_ips = [
  "10.8.0.87",
  "10.8.0.115",
  "10.8.0.128",
]
workstation_instance_id = "i-0281a8a5956684cbc"
workstation_private_ip = "10.8.0.176"
workstation_public_ip = "3.143.203.49"
```

## Retrieving output values

We'll need to use these output values in this and later lessons. If the values scroll
off the screen, we can use `terraform output` to extract them from the state
file again. That means we have to run the commands in this directory so Terraform finds
the right state, or we'll have to use the `-state=path` option to point to the
correct `terraform.tfstate` file.

```console
$ terraform output target_private_ips
[
  "10.8.0.87",
  "10.8.0.115",
  "10.8.0.128",
]
$ terraform output workstation_public_ip
"3.143.203.49"
```

## Connect to the workstation

SSH into the Ansible workstation using the `workstation_public_ip` and the key file you 
specified. The username is `ubuntu`.

```console
$ ssh -i /mnt/c/Users/GotimerEugene/.ssh/gene-test-us-east-2.pem ubuntu@3.143.203.49
The authenticity of host '3.143.203.49 (3.143.203.49)' can't be established.
ED25519 key fingerprint is SHA256:/BG/g0mHfxvYpYrMNl7fQ3A+eNg89KVA5O3LEB9f3o4.
This key is not known by any other names
Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
Warning: Permanently added '3.143.203.49' (ED25519) to the list of known hosts.
Welcome to Ubuntu 21.10 (GNU/Linux 5.13.0-1007-aws x86_64)
...
ubuntu@ip-10-8-0-176:~$
```

## Verify Ansible is installed

On the Ansible workstation, we'll run our first Ansible command to verify it
is installed correctly.

```console
ubuntu@ip-10-8-0-176:~$ ansible localhost -m ping
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

## End of Lesson 04.

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
| <a name="output_workstation_instance_id"></a> [workstation\_instance\_id](#output\_workstation\_instance\_id) | ID of the Ansible workstation instance |
| <a name="output_workstation_private_ip"></a> [workstation\_private\_ip](#output\_workstation\_private\_ip) | Private IP address of the Ansible workstation |
| <a name="output_workstation_public_ip"></a> [workstation\_public\_ip](#output\_workstation\_public\_ip) | Public IP address of the Ansible workstation |
<!-- END_TF_DOCS -->
