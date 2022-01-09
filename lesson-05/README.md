# Lesson 05 - Ansible basics

*Except where noted, these instructions should be run on the Ansible workstation
(i.e., control node) we stood up in Lesson 04.*

## Inventory file

The Ansible `ping` module we ran to verify the installation didn't do much
against `localhost` other than make sure that Ansible was installed correctly.

```console
ubuntu@ip-10-8-0-26:~$ ansible localhost -m ping
[WARNING]: No inventory was parsed, only implicit localhost is available
localhost | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
```

The `[WARNING]` mentions, accurately, that we didn't supply an inventory, which
is a list of the systems that we are managing with Ansible.

Create `inventory.ini` on the workstation listing the *private* IP addresses for
the workstation and target systems.
You can use `terraform output workstation_private_ip` and
`terraform output target_private_ips` on your laptop in the `lesson-04`
directory to get the values you need.

Either use `pico` or `vi` on the workstation via an SSH connection, or
create the file locally and use `scp` to upload it.

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
```

This inventory sets up 3 groups: `workstation`, `targets`, and a group called
`all` that is made up of the contents of the other 2 groups.

Now we can re-run the `ping` command locally and see that the `[WARNING]`
isn't displayed.

```console
ubuntu@ip-10-8-0-26:~$ ansible -i inventory.ini localhost -m ping
localhost | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
```

That didn't check anything on the other servers, though. We could run ping on
the targets to see if Ansible is able to log in and run a command on them.

```console
ubuntu@ip-10-8-0-26:~$ ansible -i inventory.ini targets -m ping
10.8.0.206 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python3"
    },
    "changed": false,
    "ping": "pong"
}
10.8.0.10 | SUCCESS => {
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
```

This showed that Ansible was able to SSH into each of the target systems and
find an acceptable version of Python.

Since we'll be using this same inventory for a while, we can update the
configuration file so we don't have to specify `inventory.ini` everytime.

Edit `.ansible.cfg` to add the `inventory` line:

```ini
[defaults]
host_key_checking = False
inventory = inventory.ini
```

Now, the command is even easier.

```console
ubuntu@ip-10-8-0-26:~$ ansible targets -m ping
10.8.0.206 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python3"
    },
    "changed": false,
    "ping": "pong"
}
10.8.0.10 | SUCCESS => {
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
```

## Ad-hoc commands

The `ping` command we've been using is an Ansible module.
Ansible also lets us run ad-hoc commands against any or all of the servers in
our inventory.

```console
ubuntu@ip-10-8-0-26:~$ ansible targets -a uptime
10.8.0.206 | CHANGED | rc=0 >>
 19:11:13 up 19 min,  1 user,  load average: 0.00, 0.00, 0.00
10.8.0.41 | CHANGED | rc=0 >>
 19:11:13 up 19 min,  1 user,  load average: 0.08, 0.02, 0.01
10.8.0.10 | CHANGED | rc=0 >>
 19:11:13 up 19 min,  1 user,  load average: 0.00, 0.00, 0.00
ubuntu@ip-10-8-0-26:~$ ansible all -a date
10.8.0.206 | CHANGED | rc=0 >>
Fri Jan  7 19:11:27 UTC 2022
10.8.0.10 | CHANGED | rc=0 >>
Fri Jan  7 19:11:28 UTC 2022
10.8.0.41 | CHANGED | rc=0 >>
Fri Jan  7 19:11:28 UTC 2022
10.8.0.26 | CHANGED | rc=0 >>
Fri Jan  7 19:11:28 UTC 2022
ubuntu@ip-10-8-0-26:~$ ansible 10.8.0.41 -a "df -k"
10.8.0.41 | CHANGED | rc=0 >>
Filesystem     1K-blocks    Used Available Use% Mounted on
/dev/root        8065444 1490360   6558700  19% /
devtmpfs          989876       0    989876   0% /dev
tmpfs             996480       0    996480   0% /dev/shm
tmpfs             199296     800    198496   1% /run
tmpfs               5120       0      5120   0% /run/lock
tmpfs             996480       0    996480   0% /sys/fs/cgroup
/dev/loop0         25600   25600         0 100% /snap/amazon-ssm-agent/4046
/dev/loop1         56832   56832         0 100% /snap/core18/2253
/dev/loop2         63488   63488         0 100% /snap/core20/1270
/dev/loop3         68864   68864         0 100% /snap/lxd/21835
/dev/loop4         44416   44416         0 100% /snap/snapd/14295
tmpfs             199296       0    199296   0% /run/user/1000
```

Keep in mind that we might not have the same environment profile as we would
if we logged in.

```console
ubuntu@ip-10-8-0-26:~$ ansible --version
ansible [core 2.12.1]
  config file = /home/ubuntu/.ansible.cfg
  configured module search path = ['/home/ubuntu/.ansible/plugins/modules', '/usr/share/ansible/plugins/modules']
  ansible python module location = /home/ubuntu/.local/lib/python3.8/site-packages/ansible
  ansible collection location = /home/ubuntu/.ansible/collections:/usr/share/ansible/collections
  executable location = /home/ubuntu/.local/bin/ansible
  python version = 3.8.10 (default, Nov 26 2021, 20:14:08) [GCC 9.3.0]
  jinja version = 2.10.1
  libyaml = True
ubuntu@ip-10-8-0-26:~$ ansible workstation -a "ansible --version"
10.8.0.26 | FAILED | rc=2 >>
[Errno 2] No such file or directory: b'ansible'
ubuntu@ip-10-8-0-26:~$ which ansible
/home/ubuntu/.local/bin/ansible
ubuntu@ip-10-8-0-26:~$ ansible workstation -a "/home/ubuntu/.local/bin/ansible --version"
10.8.0.26 | CHANGED | rc=0 >>
ansible [core 2.12.1]
  config file = /home/ubuntu/.ansible.cfg
  configured module search path = ['/home/ubuntu/.ansible/plugins/modules', '/usr/share/ansible/plugins/modules']
  ansible python module location = /home/ubuntu/.local/lib/python3.8/site-packages/ansible
  ansible collection location = /home/ubuntu/.ansible/collections:/usr/share/ansible/collections
  executable location = /home/ubuntu/.local/bin/ansible
  python version = 3.8.10 (default, Nov 26 2021, 20:14:08) [GCC 9.3.0]
  jinja version = 2.10.1
  libyaml = True
```

## Installing a software package

We can remotely install packages on servers in our inventory using the `apt`
module. Since installing software via the package manager requires
`root` or `sudo`, we will have to *become* a privileged user.

We can see what attributes are required and available in the
[module documentation](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/apt_module.html).
The `update_cache` attribute will make sure we have an up-to-date list of the
available packages so the package manager can find the package we are installing.

```console
ubuntu@ip-10-8-0-26:~$ ansible targets -a "fortune"
10.8.0.206 | FAILED | rc=2 >>
[Errno 2] No such file or directory: b'fortune'
10.8.0.10 | FAILED | rc=2 >>
[Errno 2] No such file or directory: b'fortune'
10.8.0.41 | FAILED | rc=2 >>
[Errno 2] No such file or directory: b'fortune'
ubuntu@ip-10-8-0-26:~$ ansible targets --become -m apt -a "name=fortune update_cache=true state=present"
10.8.0.206 | CHANGED => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python3"
    },
    "cache_update_time": 1641584034,
    "cache_updated": true,
    "changed": true,
...
}
10.8.0.10 | CHANGED => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python3"
    },
    "cache_update_time": 1641584034,
    "cache_updated": true,
    "changed": true,
...
}
10.8.0.41 | CHANGED => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python3"
    },
    "cache_update_time": 1641584035,
    "cache_updated": true,
    "changed": true,
...
}
ubuntu@ip-10-8-0-26:~$ ansible targets -a "fortune"
10.8.0.206 | CHANGED | rc=0 >>
Let me take you a button-hole lower.
                -- William Shakespeare, "Love's Labour's Lost"
10.8.0.10 | CHANGED | rc=0 >>
Advancement in position.
10.8.0.41 | CHANGED | rc=0 >>
You two ought to be more careful--your love could drag on for years and years.
```

## Doing system maintenance

More useful than remote generating random sayings, we could do system
maintenance using a similar ad-hoc model. Since the `apt` package list is
up-to-date now, we could use the more generic `package` module.

```console
ubuntu@ip-10-8-0-26:~$ ansible all --become -m package -a "name=liblog4j2-java state=absent"
10.8.0.206 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python3"
    },
    "changed": false
}
10.8.0.10 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python3"
    },
    "changed": false
}
10.8.0.26 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python3"
    },
    "changed": false
}
10.8.0.41 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python3"
    },
    "changed": false
}
ubuntu@ip-10-8-0-26:~$ ansible all --become -m package -a "name=mlocate state=present"
10.8.0.206 | CHANGED => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python3"
    },
    "cache_update_time": 1641584034,
    "cache_updated": false,
    "changed": true,
...
}
10.8.0.10 | CHANGED => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python3"
    },
    "cache_update_time": 1641584034,
    "cache_updated": false,
    "changed": true,
...
}
10.8.0.41 | CHANGED => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python3"
    },
    "cache_update_time": 1641584035,
    "cache_updated": false,
    "changed": true,
...
}
10.8.0.26 | CHANGED => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python3"
    },
    "cache_update_time": 1641581537,
    "cache_updated": false,
    "changed": true,
...
}
ubuntu@ip-10-8-0-26:~$ ansible all --become -a "updatedb"
10.8.0.10 | CHANGED | rc=0 >>

10.8.0.206 | CHANGED | rc=0 >>

10.8.0.41 | CHANGED | rc=0 >>

10.8.0.26 | CHANGED | rc=0 >>

ubuntu@ip-10-8-0-26:~$ ansible all -a "locate log4j"
10.8.0.206 | FAILED | rc=1 >>
non-zero return code
10.8.0.10 | FAILED | rc=1 >>
non-zero return code
10.8.0.26 | CHANGED | rc=0 >>
/home/ubuntu/.local/lib/python3.8/site-packages/ansible_collections/community/windows/tests/integration/targets/win_xml/files/log4j.xml
10.8.0.41 | FAILED | rc=1 >>
non-zero return code
```

## End of Lesson 05
