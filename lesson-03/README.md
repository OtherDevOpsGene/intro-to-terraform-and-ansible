# Lesson 03 - More Terraform variables, plans, workspaces, and security

## Plans and more variables

Terraform will run any `*.tf` file in the directory. The `plan` command is
handled automatically by `apply`, but can also be performed explicitly to see 
what Terraform will be doing without doing it.

```console
$ ls -A
.gitignore  README.md  keypair.tf  main.tf  network.tf  outputs.tf  providers.tf  variables.tf
$ terraform init
...
$ terraform plan
var.owner_email
  Email address to tag resources with

  Enter a value: eugene.gotimer@steampunk.com

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:
...
Note: You didn't use the -out option to save this plan, so Terraform can't guarantee to take exactly these actions if you run "terraform apply" now.
```

A variable specified like this will need to be set each time, making it manual
to repeat a build.

Sometimes values will be set for each user, but will remain constant once set. 
We can put those values in a `terraform.tfvars` file or any filename ending in 
`.auto.tfvars`.

Create `terraform.tfvars`:

```terraform
owner_email = "eugene.gotimer@steampunk.com"
key_name = "gene-test-us-east-2"
```

Other values might change from run to run, so we can specify them at runtime.
Terraform will load any environment variable named `TF_VAR_<variable_name>`.

```console
export TF_VAR_aws_region='us-east-2'
```

This time we aren't asked for the variable values.

```console
$ terraform plan

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:
...
Note: You didn't use the -out option to save this plan, so Terraform can't guarantee to take exactly these actions if you run "terraform apply" now.
```

The note points out that the settings it is showing were only at the time 
`plan` was run, and might change when `apply` is run. E.g., the `TF_VAR_aws_region`
environment variable could be changed. We can save that plan and pass it to 
`apply` to avoid surprises.

```console
$ terraform plan -out=lesson-03.tfplan

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:
...
Saved the plan to: lesson-03.tfplan

To perform exactly these actions, run the following command to apply:
    terraform apply "lesson-03.tfplan"
$ terraform apply "lesson-03.tfplan"
...
Apply complete! Resources: 14 added, 0 changed, 0 destroyed.

Outputs:
...
```

## Workspaces and variable files

Sometimes we want to use different values for different runs, e.g., each
different environment. We can combine workspaces and `.tfvars` files to work on
more than one environment at once and so we don't have to specify the values 
each time.

In `main.tf`, make the webserver `instance_type` a variable:

```terraform
resource "aws_instance" "webserver" {
...
  instance_type = var.instance_type
```

Now create variable files with the values for each environment we want to
be able to configure.

Add the variable to `variables.tf`:

```terraform
variable "instance_type" {
  description = "Webserver instance type"
  type = string
}
```

Create `dev.tfvars`:
```terraform
instance_type = "t2.micro"
```

Create `prod.tfvars`:
```terraform
instance_type = "t2.medium"
```

We can work on more than one environment while in this directory using 
workspaces. Until now, we've been working in the `default` workspace
(notice the `*` which means selected).

```console
$ terraform workspace list
* default

$ terraform workspace new dev
Created and switched to workspace "dev"!

You're now on a new, empty workspace. Workspaces isolate their state,
so if you run "terraform plan" Terraform will not see any existing state
for this configuration.
$ terraform workspace select dev
$ terraform apply -var-file=dev.tfvars

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:
...
$ terraform workspace new prod
Created and switched to workspace "prod"!

You're now on a new, empty workspace. Workspaces isolate their state,
so if you run "terraform plan" Terraform will not see any existing state
for this configuration.
$ terraform workspace select prod
$ terraform apply -var-file=prod.tfvars

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:
...
```

## Idempotency

As we've seen, Terraform will not make any changes that it doesn't need to. If a
resource is already correctly configured, it doesn't recreate it or make any changes.

```console
$ terraform apply
...
No changes. Your infrastructure matches the configuration.

Your configuration already matches the changes detected above. If you'd like to update the Terraform state to match, create and apply a refresh-only plan:
  terraform apply -refresh-only

Apply complete! Resources: 0 added, 0 changed, 0 destroyed.
...
$ terraform apply -refresh-only
...
No changes. Your infrastructure still matches the configuration.

Terraform has checked that the real remote objects still match the result of your most recent changes, and found no differences.

Would you like to update the Terraform state for "prod" to reflect these detected changes?
  Terraform will write these changes to the state without modifying any real infrastructure.
  There is no undo. Only 'yes' will be accepted to confirm.

  Enter a value: yes


Apply complete! Resources: 0 added, 0 changed, 0 destroyed.

Outputs:
...
```

If we want to force the replacement of a resource that otherwise would not
change (e.g., replace an EC2 instance that was corrupted at the system level,
but the instance configuration remains intact), we can explicitly recreate it.
The command used to be called `terraform taint`, but now `terraform apply` is
preferred.

```console
$ terraform state list
data.aws_ami.ubuntu_linux
aws_default_security_group.default
aws_eip.webserver_eip[0]
aws_eip.webserver_eip[1]
aws_instance.webserver[0]
aws_instance.webserver[1]
aws_internet_gateway.sandbox_gateway
aws_route_table.rtb_public
aws_route_table_association.rta_subnet_public
aws_security_group.webserver_sg
aws_subnet.public_subnet
aws_vpc.sandbox_vpc
$ terraform apply -replace="aws_instance.webserver[0]"
...
Terraform will perform the following actions:
...
  # aws_instance.webserver[0] will be replaced, as requested
```

## Clean up

We can clean up what we created, in each workspace.

```console
$ terraform workspace list
  default
  dev
* prod

$ terraform destroy
...
Destroy complete! Resources: 11 destroyed.
$ terraform workspace select dev
Switched to workspace "dev".
$ terraform destroy
...
Destroy complete! Resources: 11 destroyed.
$ terraform workspace select default
Switched to workspace "default".
$ terraform destroy
...
Destroy complete! Resources: 11 destroyed.
$ terraform workspace list
* default
  dev
  prod
```

## Static analysis and security

This example had many resources. Remembering to apply all the recommended
practices can be daunting. Fortunately, there are a number of tools we can use
to clean up our code and environments.

### terraform fmt

The built-in `terraform fmt` command will update any Terraform files in the current
directory to make the formatting consistent. Any files that are changed will be
listed.

```console
$ terraform fmt
main.tf
terraform.tfvars
variables.tf
```

### TFLint

> TFLint is a framework and each feature is provided by plugins, the key features are as follows:
>
> * Find possible errors (like illegal instance types) for Major Cloud providers (AWS/Azure/GCP).
> * Warn about deprecated syntax, unused declarations.
> * Enforce best practices, naming conventions.

[TFLint](https://github.com/terraform-linters/tflint) can be installed from
GitHub. The AWS plugin (or Azure or GCP, if we use those providers) should be
added as well.

Create a configuration file as `.tflint.hcl`:

```terraform
plugin "aws" {
  enabled = true
  version = "0.10.1"
  source  = "github.com/terraform-linters/tflint-ruleset-aws"
}
```

Install TFLint (shown for Linux):

```console
$ curl -s https://raw.githubusercontent.com/terraform-linters/tflint/master/install_linux.sh | bash
...
Looking up the latest version ...
...
Current tflint version
TFLint version 0.34.1
```

Initialize the configuration once, and then we can use `tflint` to review our
code.

```console
$ tflint --init
Installing `aws` plugin...
Installed `aws` (source: github.com/terraform-linters/tflint-ruleset-aws, version: 0.10.1)
$ tflint
1 issue(s) found:

Error: "t2x.micro" is an invalid value as instance_type (aws_instance_invalid_type)

  on main.tf line 23:
  23:   instance_type          = "t2x.micro"
```

### Checkov

> Checkov is a static code analysis tool for infrastructure-as-code.
> 
> It scans cloud infrastructure provisioned using Terraform, Terraform plan, Cloudformation, AWS SAM, Kubernetes, 
> Dockerfile, Serverless or ARM Templates and detects security and compliance misconfigurations using graph-based scanning.

[Checkov](https://github.com/bridgecrewio/checkov) is a Python 3.7+ application
and can be installed with all its dependencies using `pip`.

```console
$ python --version
Python 3.8.10
$ pip3 install checkov
...
Successfully installed aiodns-3.0.0 aiohttp-3.8.1 aiomultiprocess-0.9.0 aiosignal-1.2.0 async-timeout-4.0.2 bc-python-hcl2-0.3.28 cachetools-5.0.0 cffi-1.15.0 charset-normalizer-2.0.9 checkov-2.0.692 click-8.0.3 cyclonedx-python-lib-0.12.3 frozenlist-1.2.0 multidict-5.2.0 packageurl-python-0.9.6 pycares-4.1.2 pycparser-2.21 setuptools-60.1.0 types-setuptools-57.4.4 types-toml-0.10.1 yarl-1.7.2
```

The rules change often (more often than weekly), so be sure to update frequently.

```console
$ pip3 install -U checkov
```

And then scan a file or directory to find misconfigurations and suggestions.
Problems and often solutions are linked in the output. 

```console
$ checkov -f network.tf
...
$ checkov -d .
       _               _
   ___| |__   ___  ___| | _______   __
  / __| '_ \ / _ \/ __| |/ / _ \ \ / /
 | (__| | | |  __/ (__|   < (_) \ V /
  \___|_| |_|\___|\___|_|\_\___/ \_/

By bridgecrew.io | version: 2.0.692

terraform scan results:

Passed checks: 10, Failed checks: 5, Skipped checks: 0
...
```

Not all recommendations will always apply, but keep in mind they are
recommendations for a reason. Whenever we ignore any of the suggestions, we are
accepting some amount of risk.

## End of Lesson 03.
