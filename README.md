# intro-to-terraform-and-ansible

A hands-on workshop to become familiar with [Hashicorp Terraform](https://www.terraform.io/)
to provision and configure infrastructure and [Red Hat Ansible](https://github.com/ansible/ansible)
to configure systems and deploy applications.

## Lessons

### Terraform lessons

* [Lesson-01](lesson-01/README.md) - Terraform basics
* [Lesson-02](lesson-02/README.md) - Terraform variables, output, and data
* [Lesson-03](lesson-03/README.md) - More Terraform variables, plans, workspaces, and security
* [Lesson-04](lesson-04/README.md) - Building an Ansible sandbox

### Ansible lessons

* [Lesson-05](lesson-05/README.md) - Ansible basics
* [Lesson-06](lesson-06/README.md) - Playbook basics
* [Lesson-07](lesson-07/README.md) - Practical Ansible
* [Lesson-08](lesson-08/README.md) - Full web application

### Demo

* [Demo-09](demo-09/README.md) - Putting it all together

## Reference documentation

* [Terraform AWS provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
* [Ansible built-in plugins](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/)

## Prerequisites

To get the most out of this workshop, you will need the following:

* Terraform installed
* SSH client
* AWS account with adequate permissions
* AWS CLI installed and configured
* AWS EC2 key pair

### Terraform

[Install Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli?in=terraform/aws-get-started)
on your laptop and make sure it is on your path.

```console
$ terraform --version
Terraform v1.5.0
on linux_amd64
```

### SSH client

You should have an SSH client installed and be familiar with using it.
[PuTTY](https://www.putty.org/) is an option for Windows, but most Windows users
will be better served with the client that comes with [Git Bash](https://gitforwindows.org/).
Other OSes likely have the client already installed.

```console
$ ssh -V
OpenSSH_8.2p1 Ubuntu-4ubuntu0.7, OpenSSL 1.1.1f  31 Mar 2020
```

### AWS account with adequate permissions

You'll need an AWS account. The [AWS Free Tier](https://aws.amazon.com/free/)
is sufficient.

If you are not the root account holder, make sure you have sufficient permissions
to create EC2 instances. The AWS Managed `AmazonEC2FullAccess` policy should be
enough.

You will need an `AWS Access Key ID` and `AWS Secret Access Key` available to you.
[Creating an access key](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_access-keys.html)
specifically for this workshop might be a good idea.

### AWS CLI installed and configured

You must install the [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
and configure it to use the `AWS Access Key ID` and `AWS Secret Access Key` you
created previously.

Use `aws configure` to [set up](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-quickstart.html)
the AWS CLI to use them.

Ensure the configuration is in place and you can access AWS via the CLI.

```console
$ aws configure
AWS Access Key ID [****************5W7F]:
AWS Secret Access Key [****************G9m9]:
Default region name [us-east-2]:
Default output format [json]:
$ aws sts get-caller-identity
{
    "UserId": "AIDA6J6IBOTSMECN2JXTM",
    "Account": "983430165732",
    "Arn": "arn:aws:iam::983430165732:user/gene.gotimer-terraform"
}
```

### AWS EC2 key pair

[Create an EC2 key pair](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-key-pairs.html#having-ec2-create-your-key-pair)
and configure your SSH client to use it. Some clients (*cough* PuTTY *cough*)
need the key converted for use, so pay attention to your SSH client documentation.

```console
$ aws ec2 describe-key-pairs
{
    "KeyPairs": [
        {
            "KeyPairId": "key-0343183b6656b1f95",
            "KeyFingerprint": "c9:26:37:46:e7:43:a4:c5:e4:61:a0:d8:ac:7b:54:f0:3b:9f:8d:99",
            "KeyName": "gene-test-us-east-2",
            "KeyType": "rsa",
            "Tags": [],
            "CreateTime": "2023-03-08T20:34:04.339000+00:00"
        }
    ]
}
```

We will be copying the public **and private** keys on to AWS EC2 instances, so you
might want to create a key pair just for this workshop and then delete it immediately
after, just in case.
