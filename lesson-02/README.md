# Lesson 02 - Terraform variables, output, and data

## Variables

Start with almost the same definition we had last time.

```terraform
resource "aws_instance" "app_server" {
  ami           = "ami-0629230e074c580f2"
  instance_type = "t2.micro"

  tags = {
    Name = "tf-lesson-02"
  }
}
```

```console
$ terraform init
...
$ terraform apply

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # aws_instance.my_server will be created
  + resource "aws_instance" "app_server" {
...

Plan: 1 to add, 0 to change, 0 to destroy.

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

aws_instance.app_server: Creating...
aws_instance.app_server: Still creating... [10s elapsed]
aws_instance.app_server: Still creating... [20s elapsed]
aws_instance.app_server: Still creating... [30s elapsed]
aws_instance.app_server: Creation complete after 33s [id=i-01d1efdc6bd9ae04d]

Apply complete! Resources: 1 added, 0 changed, 0 destroyed.
```

But now let's make the name tag variable by adding a `variables.tf` file:

```terraform
variable "instance_name" {
  description = "Value of the Name tag for the EC2 instance"
  type        = string
  default     = "app-server"
}
```

and change the tag definition to:

```terraform
  tags = {
    Name = var.instance_name
  }
```

```console
$ terraform apply
aws_instance.app_server: Refreshing state... [id=i-01d1efdc6bd9ae04d]

No changes. Your infrastructure matches the configuration.

Terraform has compared your real infrastructure against your configuration and found no differences, so no changes
are needed.

Apply complete! Resources: 0 added, 0 changed, 0 destroyed.
```

There was nothing to change because the variable still had the same value we
started with. It doesn't matter how it was defined, only that the results are
the same.

Let's change the name on the fly.

```console
$ terraform apply -var 'instance_name=tf-lesson-02'
aws_instance.app_server: Refreshing state... [id=i-01d1efdc6bd9ae04d]

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with
the following symbols:
  ~ update in-place

Terraform will perform the following actions:

  # aws_instance.app_server will be updated in-place
  ~ resource "aws_instance" "app_server" {
        id                                   = "i-01d1efdc6bd9ae04d"
      ~ tags                                 = {
          ~ "Name" = "app-server" -> "tf-lesson-02"
        }
      ~ tags_all                             = {
          ~ "Name" = "app-server" -> "tf-lesson-02"
        }
        # (27 unchanged attributes hidden)

        # (5 unchanged blocks hidden)
    }

Plan: 0 to add, 1 to change, 0 to destroy.

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

aws_instance.app_server: Modifying... [id=i-01d1efdc6bd9ae04d]
aws_instance.app_server: Modifications complete after 2s [id=i-01d1efdc6bd9ae04d]

Apply complete! Resources: 0 added, 1 changed, 0 destroyed.
```

The variable value is saved in the state, but it isn't saved for future runs.

```console
$ terraform apply
aws_instance.app_server: Refreshing state... [id=i-01d1efdc6bd9ae04d]

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with
the following symbols:
  ~ update in-place

Terraform will perform the following actions:

  # aws_instance.app_server will be updated in-place
  ~ resource "aws_instance" "app_server" {
        id                                   = "i-01d1efdc6bd9ae04d"
      ~ tags                                 = {
          ~ "Name" = "tf-lesson-02" -> "app-server"
        }
      ~ tags_all                             = {
          ~ "Name" = "tf-lesson-02" -> "app-server"
        }
        # (27 unchanged attributes hidden)

        # (5 unchanged blocks hidden)
    }

Plan: 0 to add, 1 to change, 0 to destroy.

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

aws_instance.app_server: Modifying... [id=i-01d1efdc6bd9ae04d]
aws_instance.app_server: Modifications complete after 2s [id=i-01d1efdc6bd9ae04d]

Apply complete! Resources: 0 added, 1 changed, 0 destroyed.
```

## Output

We can specify data to be displayed at the end of the `apply` by creating an
`outputs.tf` file.

```terraform
output "app_server_instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.app_server.id
}

output "app_server_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.app_server.public_ip
}
```

Even without make other changes, this will change the state.

```console
$ terraform apply
aws_instance.app_server: Refreshing state... [id=i-01d1efdc6bd9ae04d]

Changes to Outputs:
  + app_server_instance_id = "i-01d1efdc6bd9ae04d"
  + app_server_public_ip   = "18.118.156.77"

You can apply this plan to save these new output values to the Terraform state, without changing any real
infrastructure.

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes


Apply complete! Resources: 0 added, 0 changed, 0 destroyed.

Outputs:

app_server_instance_id = "i-01d1efdc6bd9ae04d"
app_server_public_ip = "18.118.156.77"
```

If there were multiple instances, say `count = 2`, we can output the whole
list using `[*]`.

```terraform
output "app_server_instance_ids" {
  description = "IDs of the EC2 instance"
  value       = aws_instance.app_server[*].id
}

output "app_server_public_ips" {
  description = "Public IP addresses of the EC2 instance"
  value       = aws_instance.app_server[*].public_ip
}
```

And in `main.tf`

```terraform
resource "aws_instance" "app_server" {
  count         = 2
  ami           = "ami-0629230e074c580f2"
  instance_type = "t2.micro"

  tags = {
    Name = "${var.instance_name}-${count.index}"
  }
}
```

```console
terraform apply
aws_instance.app_server[0]: Refreshing state... [id=i-01d1efdc6bd9ae04d]
...

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with
the following symbols:
  + create
  ~ update in-place

Terraform will perform the following actions:

  # aws_instance.app_server[0] will be updated in-place
...
  # aws_instance.app_server[1] will be created
...

Plan: 1 to add, 1 to change, 0 to destroy.

Changes to Outputs:
  - app_server_instance_id  = "i-01d1efdc6bd9ae04d" -> null
  + app_server_instance_ids = [
      + "i-01d1efdc6bd9ae04d",
      + (known after apply),
    ]
  - app_server_public_ip    = "18.118.156.77" -> null
  + app_server_public_ips   = [
      + "18.118.156.77",
      + (known after apply),
    ]

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

aws_instance.app_server[1]: Creating...
aws_instance.app_server[0]: Modifying... [id=i-01d1efdc6bd9ae04d]
aws_instance.app_server[0]: Modifications complete after 2s [id=i-01d1efdc6bd9ae04d]
aws_instance.app_server[1]: Still creating... [10s elapsed]
aws_instance.app_server[1]: Still creating... [20s elapsed]
aws_instance.app_server[1]: Still creating... [30s elapsed]
aws_instance.app_server[1]: Creation complete after 33s [id=i-013547aa4d86f252e]

Apply complete! Resources: 1 added, 1 changed, 0 destroyed.

Outputs:

app_server_instance_ids = [
  "i-01d1efdc6bd9ae04d",
  "i-013547aa4d86f252e",
]
app_server_public_ips = [
  "18.118.156.77",
  "18.118.14.152",
]
```

## Data

The AMI ID `ami-0629230e074c580f2` is an image for Ubuntu 20.04 LTS in us-east-2.
The Ubuntu image list can found at <https://cloud-images.ubuntu.com/locator/ec2/>.

Rather than hard-coding the AMI ID, we can look it up at provisioning time.

```terraform
data "aws_ami" "ubuntu_linux" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-*-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_instance" "app_server" {
  count         = 2
  ami           = data.aws_ami.ubuntu_linux.id
  instance_type = "t2.micro"

  tags = {
    Name = "${var.instance_name}-${count.index}"
  }
}
```

```console
$ terraform apply
aws_instance.app_server[1]: Refreshing state... [id=i-013547aa4d86f252e]
aws_instance.app_server[0]: Refreshing state... [id=i-01d1efdc6bd9ae04d]

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with
the following symbols:
-/+ destroy and then create replacement

Terraform will perform the following actions:

  # aws_instance.app_server[0] must be replaced
-/+ resource "aws_instance" "app_server" {
      ~ ami                                  = "ami-0629230e074c580f2" -> "ami-0fb653ca2d3203ac1" # forces replacement
...
Plan: 2 to add, 0 to change, 2 to destroy.
```

Because the AMI changes, the images need to be recreated.

Notice the `destroy then create replacement`, which would mean that we would have
downtime if we were to keep replacing the AMI to stay current.

We can change the lifecycle to make sure it stands up the new instances and then
destroys the old so that we don't have unavailability (at the cost of having more
servers running for a short period of time).

```terraform
resource "aws_instance" "app_server" {
  lifecycle {
    create_before_destroy = true
  }

  count         = 2
  ami           = data.aws_ami.ubuntu_linux.id
  instance_type = "t2.micro"

  tags = {
    Name = "${var.instance_name}-${count.index}"
  }
}
```

```console
$ terraform apply
aws_instance.app_server[1]: Refreshing state... [id=i-013547aa4d86f252e]
aws_instance.app_server[0]: Refreshing state... [id=i-01d1efdc6bd9ae04d]

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with
the following symbols:
+/- create replacement and then destroy

Terraform will perform the following actions:

  # aws_instance.app_server[0] must be replaced
+/- resource "aws_instance" "app_server" {
      ~ ami                                  = "ami-0629230e074c580f2" -> "ami-0fb653ca2d3203ac1" # forces replacement
...
Plan: 2 to add, 0 to change, 2 to destroy.
```

## Clean up

We can clean up what we created.

```console
$ terraform destroy
```

## End of Lesson 02
