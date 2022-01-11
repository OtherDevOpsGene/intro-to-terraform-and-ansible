# Lesson 07 - Practical Ansible

*Except where noted, these instructions should be run on the Ansible workstation
(i.e., control node) we stood up in Lesson 04.*

Often the applications we are deploying involve than just one system. And the
packages we deploy usually need some custom configuration, defining directories
and permissions, or pointing a web application to the database backend, for example.

## Web application architecture

A typical web application might involve a pair of load-balanced web servers with
a database backend. For our purposes, we'll skip the load balancer and use
two of our three targets as [NGINX](https://www.nginx.com/) web servers.
The remaining target will be a [MongoDB](https://www.mongodb.com/) database server.

Update the `inventory.ini` to add these groups so we can refer to the servers easily.

```ini
[workstation]
10.8.0.26

[targets]
10.8.0.10
10.8.0.41
10.8.0.206

[all:children]
workstation
targets

[webservers]
10.8.0.41
10.8.0.206

[database]
10.8.0.10
```

Test them with a `ping`.

```console
ubuntu@ip-10-8-0-26:~$ ansible webservers -m ping
10.8.0.206 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python3"
    },
    "changed": false,
    "ping": "pong"
}
10.8.0.41 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python3"
    },
    "changed": false,
    "ping": "pong"
}
ubuntu@ip-10-8-0-26:~$ ansible database -m ping
10.8.0.10 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python3"
    },
    "changed": false,
    "ping": "pong"
}
```

## Ansible Galaxy

Installing NGINX and MongoDB are a little more involved than installing a single
package each as we did with `fortune` and `cowsay`. Fortunately, both are popular
software and someone else has already come up with code we can use. The public
repository for sharing that code is [Ansible Galaxy](https://galaxy.ansible.com/).

The software on Ansible Galaxy is community supported and varies wildly in
quality and capability. It is best to look for code published by Ansible themselves
(listed as `community`), the product owners (e.g., `nginxinc`) or popular items
(e.g., anything published by `geerlingguy`).

We will use the [geerlingguy.nginx](https://galaxy.ansible.com/geerlingguy/nginx) role
and the [community.mongodb](https://galaxy.ansible.com/community/mongodb) collection.
The Galaxy pages have information on how to use them.
First, we need to install them on our control node so Ansible can use them.

```console
ubuntu@ip-10-8-0-26:~$ ansible-galaxy install geerlingguy.nginx
Starting galaxy role install process
- downloading role 'nginx', owned by geerlingguy
- downloading role from https://github.com/geerlingguy/ansible-role-nginx/archive/3.1.0.tar.gz
- extracting geerlingguy.nginx to /home/ubuntu/.ansible/roles/geerlingguy.nginx
- geerlingguy.nginx (3.1.0) was installed successfully
ubuntu@ip-10-8-0-26:~$ ansible-galaxy collection install community.mongodb
Starting galaxy collection install process
Process install dependency map
Starting collection install process
Downloading https://galaxy.ansible.com/download/community-mongodb-1.3.2.tar.gz to /home/ubuntu/.ansible/tmp/ansible-local-9402dmuftl1q/tmp2sh_o8my/community-mongodb-1.3.2-kbwytqfq
Installing 'community.mongodb:1.3.2' to '/home/ubuntu/.ansible/collections/ansible_collections/community/mongodb'
Downloading https://galaxy.ansible.com/download/ansible-posix-1.3.0.tar.gz to /home/ubuntu/.ansible/tmp/ansible-local-9402dmuftl1q/tmp2sh_o8my/ansible-posix-1.3.0-jfe0its2
community.mongodb:1.3.2 was installed successfully
Installing 'ansible.posix:1.3.0' to '/home/ubuntu/.ansible/collections/ansible_collections/ansible/posix'
Downloading https://galaxy.ansible.com/download/community-general-4.2.0.tar.gz to /home/ubuntu/.ansible/tmp/ansible-local-9402dmuftl1q/tmp2sh_o8my/community-general-4.2.0-y5t748ev
ansible.posix:1.3.0 was installed successfully
Installing 'community.general:4.2.0' to '/home/ubuntu/.ansible/collections/ansible_collections/community/general'
community.general:4.2.0 was installed successfully
```

## Installing NGINX

The `geerlingguy.nginx` role in an Ansible role, which is a package of at least
tasks and metadata code, and could include more code collected into
[standard directories](https://docs.ansible.com/ansible/latest/user_guide/playbooks_reuse_roles.html#id2).

```
playbook.yml
roles/
  rolename/
    tasks/
    handlers/
    library/
    files/
    templates/
    vars/
    defaults/
    meta/
```

We don't have to worry about that right now since `geerlingguy` already did. We
just have to supply the playbook.

Create [nginx-playbook.yml](./nginx-playbook.yml) on the control node to call the role.
We want the role applied to our `webservers` group. Since we'll be installing packages,
we'll need elevated privileges. The Read Me on Galaxy shows which variables to
supply and then we can leave the rest to the role.

```yaml
---
- hosts: webservers
  become: true

  vars:
    nginx_vhosts:
      - listen: "80"
        server_name: "example.com"

  roles:
    - {role: geerlingguy.nginx}
```

Then run our playbook.

```console
ubuntu@ip-10-8-0-26:~$ ansible-playbook nginx-playbook.yml

PLAY [webservers] ******************************************************************************************************************
...
PLAY RECAP *************************************************************************************************************************
10.8.0.206                 : ok=14   changed=4    unreachable=0    failed=0    skipped=8    rescued=0    ignored=0
10.8.0.41                  : ok=14   changed=4    unreachable=0    failed=0    skipped=8    rescued=0    ignored=0
```

We need to find out what the public IP addresses for the targets are, knowing
that 2 of the 3 of them are our web servers.

On our laptop, go to the `lesson-04` directory and pull up the Terraform output again.

```console
$ cd ../lesson-04
$ terraform output target_public_ips
[
  "18.117.70.148",
  "18.188.98.141",
  "18.116.43.247",
]
```

If we point a web browser to those IP addresses, we should see a web page on 2 of them.

<kbd>
  <img alt="Welcome to nginx!" src="../screenshots/welcome-to-nginx.png"/>
</kbd>

That works, but we really want something a little more bespoke. We can add some
more configuration to the playbook and include a new home page. Add another variable
and a task to `nginx-playbook.yml`.

```yaml
---
- hosts: webservers
  become: true

  vars:
    my_name: "Gene"
    nginx_vhosts:
      - listen: "80"
        server_name: "example.com"

  roles:
    - {role: geerlingguy.nginx}

  tasks:
    - name: Install a custom home page
      template:
        src: index.html.j2
        dest: /var/www/html/index.html
        owner: www-data
        group: www-data
        mode: 0644
```

The [template](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/template_module.html)
module uses Jinja2 to create a new home page for us. We need to create the
[index.html.j2](./index.html.j2) template on the control node as well.

```html
<!DOCTYPE html>
<html lang="en" xml:lang="en">
<head>
    <title>Hello, {{ my_name }}!</title>
    <style>
        body {
            width: 35em;
            margin: 0 auto;
            font-family: Tahoma, Verdana, Arial, sans-serif;
        }
    </style>
</head>

<body>
<h1 align="center">Hello, {{ my_name }}!</h1>

<p>This is just a static HTML page that we created in the
    Intro to Terraform and Ansible workshop.</p>

<p>This web server is running on {{ ansible_hostname }} which is
    running {{ ansible_lsb.description }} ({{ ansible_lsb.codename }}).
</body>
</html>
```

This time when we run the playbook, we see that the new task was executed and it
was the only play that changed. The rest of the plays were idempotent.

```console
ubuntu@ip-10-8-0-26:~$ ansible-playbook nginx-playbook.yml

PLAY [webservers] ******************************************************************************************************************
...
TASK [Install a custom home page] **************************************************************************************************
changed: [10.8.0.206]
changed: [10.8.0.41]

PLAY RECAP *************************************************************************************************************************
10.8.0.206                 : ok=14   changed=1    unreachable=0    failed=0    skipped=8    rescued=0    ignored=0
10.8.0.41                  : ok=14   changed=1    unreachable=0    failed=0    skipped=8    rescued=0    ignored=0
```

<kbd>
  <img alt="Hello, Gene!" src="../screenshots/hello-gene.png"/>
</kbd>

## Installing MongoDB

We'll use MongoDB as our database backend. Create [mongodb-playbook.yml](./mongodb-playbook.yml) on the control 
node to call
the role.

```yaml
---
- hosts: database
  become: true
  collections:
    - community.mongodb

  roles:
    - mongodb_linux
    - {role: mongodb_repository, mongodb_version: "5.0"}
    - mongodb_install
    - {role: mongodb_mongod, bind_ip: "localhost,{{ ansible_default_ipv4.address }}", replicaset: false}
```

```console
ubuntu@ip-10-8-0-26:~$ ansible-playbook mongodb-playbook.yml

PLAY [database] ********************************************************************************************************************
...
PLAY RECAP *************************************************************************************************************************
10.8.0.10                  : ok=20   changed=11   unreachable=0    failed=0    skipped=5    rescued=0    ignored=0
```

Let's verify from the control node that the `mongod` service is running on our database node, meaning that MongoDB is
installed and running, even if we aren't using it yet.

```console
ubuntu@ip-10-8-0-26:~$ ansible database -m service -a 'name=mongod state=started' --check
10.8.0.10 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python3"
    },
    "changed": false,
    "name": "mongod",
    "state": "started",
...
```

So we have two web servers with a templated home page and an empty database installed.
The next step is to put them together.

## End of Lesson 07

In the final lesson, we'll expand upon this set up and stand up
[a full web application](../lesson-08/README.md).
