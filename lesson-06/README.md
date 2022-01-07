# Lesson 06 - Playbook basics

*Except where noted, these instructions should be run on the Ansible workstation
(i.e., control node) we stood up in Lesson 04.*

Using Ansible for ad-hoc tasks might be a convenience for investigations or
emergencies, but we really want to use Ansible to focus on repeatability and
infrastructure-as-code.

## Playbooks

Generally, we prefer to create files that can be re-run and reused
instead of relying on memory, notes, and or shell history to record
the actions we take.

In Ansible, we can create a playbook that accomplishes the same configuration
as the ad-hoc commands we ran in the last lesson.

For example, rework the `fortune` example by copying
[fortune-playbook.yml](./fortune-playbook.yml) to the control node and run it as
a playbook.

```yaml
---
- hosts: targets

  tasks:
  - name: Install the fortune package
    apt:
      name: fortune
      state: present
      update_cache: true
    become: true

  - name: Run fortune
    command: fortune
    register: fortune_out

  - name: Display fortune results
    debug:
      var: fortune_out.stdout
```

```console
ubuntu@ip-10-8-0-26:~$ ansible-playbook fortune-playbook.yml

PLAY [targets] *********************************************************************************************************************

TASK [Gathering Facts] *************************************************************************************************************
ok: [10.8.0.206]
ok: [10.8.0.188]
ok: [10.8.0.209]

TASK [Install the fortune package] *************************************************************************************************
ok: [10.8.0.188]
ok: [10.8.0.206]
ok: [10.8.0.209]

TASK [Run fortune] *****************************************************************************************************************
changed: [10.8.0.206]
changed: [10.8.0.188]
changed: [10.8.0.209]

TASK [Display fortune results] *****************************************************************************************************
ok: [10.8.0.188] => {
    "fortune_out.stdout": "It is a wise father that knows his own child.\n\t\t-- William Shakespeare, \"The Merchant of Venice\""
}
ok: [10.8.0.209] => {
    "fortune_out.stdout": "If more of us valued food and cheer and song above hoarded gold, it would\nbe a merrier world.\n\t\t-- J.R.R. Tolkien"
}
ok: [10.8.0.206] => {
    "fortune_out.stdout": "Q:\tWhat lies on the bottom of the ocean and twitches?\nA:\tA nervous wreck."
}

PLAY RECAP *************************************************************************************************************************
10.8.0.188                 : ok=4    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
10.8.0.206                 : ok=4    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
10.8.0.209                 : ok=4    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0

```

We can extend the example to use additional packages as well.

Copying
[cowsay-playbook.yml](./fortune-playbook.yml) to the control node and run it as
a playbook.

```yaml
---
- hosts: targets

  tasks:
  - name: Install the fortune package
    apt:
      name: fortune
      state: present
      update_cache: true
    become: true

  - name: Run fortune
    command: fortune
    register: fortune_out

  - name: Install the cowsay package
    apt:
      name: cowsay
      state: present
    become: true

  - name: Run cowsay
    command: "cowsay \"{{ ansible_hostname }}: {{ fortune_out.stdout }}\""
    register: cowsay_out

  - name: Display cowsay results
    debug:
      var: cowsay_out.stdout_lines
```

```console
ubuntu@ip-10-8-0-26:~$ ansible-playbook cowsay-playbook.yml

PLAY [targets] *********************************************************************************************************************

TASK [Gathering Facts] *************************************************************************************************************
ok: [10.8.0.188]
ok: [10.8.0.206]
ok: [10.8.0.209]

TASK [Install the fortune package] *************************************************************************************************
ok: [10.8.0.206]
ok: [10.8.0.188]
ok: [10.8.0.209]

TASK [Run fortune] *****************************************************************************************************************
changed: [10.8.0.206]
changed: [10.8.0.188]
changed: [10.8.0.209]

TASK [Install the cowsay package] **************************************************************************************************
changed: [10.8.0.206]
changed: [10.8.0.188]
changed: [10.8.0.209]

TASK [Run cowsay] ******************************************************************************************************************
changed: [10.8.0.188]
changed: [10.8.0.206]
changed: [10.8.0.209]

TASK [Display cowsay results] ******************************************************************************************************
ok: [10.8.0.188] => {
    "cowsay_out.stdout_lines": [
        " ________________________________________",
        "/ ip-10-8-0-188: You will win success in \\",
        "\\ whatever calling you adopt.            /",
        " ----------------------------------------",
        "        \\   ^__^",
        "         \\  (oo)\\_______",
        "            (__)\\       )\\/\\",
        "                ||----w |",
        "                ||     ||"
    ]
}
ok: [10.8.0.209] => {
    "cowsay_out.stdout_lines": [
        " ________________________________________",
        "/ ip-10-8-0-209: You'll feel much better \\",
        "\\ once you've given up hope.             /",
        " ----------------------------------------",
        "        \\   ^__^",
        "         \\  (oo)\\_______",
        "            (__)\\       )\\/\\",
        "                ||----w |",
        "                ||     ||"
    ]
}
ok: [10.8.0.206] => {
    "cowsay_out.stdout_lines": [
        " ________________________________________",
        "/ ip-10-8-0-206: You will be run over by \\",
        "\\ a bus.                                 /",
        " ----------------------------------------",
        "        \\   ^__^",
        "         \\  (oo)\\_______",
        "            (__)\\       )\\/\\",
        "                ||----w |",
        "                ||     ||"
    ]
}

PLAY RECAP *************************************************************************************************************************
10.8.0.188                 : ok=6    changed=3    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
10.8.0.206                 : ok=6    changed=3    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
10.8.0.209                 : ok=6    changed=3    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
```

The `ansible_hostname` comes from the implicit `Gathering Facts` task. You can see
what information Ansible knows for a host using the `setup` module.

```console
ubuntu@ip-10-8-0-26:~$ ansible 10.8.0.209 -m setup | less
10.8.0.209 | SUCCESS => {
    "ansible_facts": {
...
        "ansible_hostname": "ip-10-8-0-209",
...
    "changed": false
}

```

The `{{ }}` notation is a
[Jinja2 expression](https://docs.ansible.com/ansible/latest/user_guide/playbooks_templating.html)
that can be used in variables or templates. We'll do more with templates in the
next lesson.

## Ansible Lint

Just as we checked our Terraform code with TFLint and Checkov, we can check our
Ansible playbooks for recommended practices using
[Ansible Lint](https://ansible-lint.readthedocs.io/).

Install Ansible Lint on the control node using `pip3`.

```console
ubuntu@ip-10-8-0-26:~$ pip3 install --user ansible-lint
Collecting ansible-lint
  Downloading ansible_lint-5.3.1-py3-none-any.whl (114 kB)
...
Installing collected packages: pygments, commonmark, rich, enrich, tenacity, bracex, wcmatch, ruamel.yaml.clib, ruamel.yaml, ansible-lint
Successfully installed ansible-lint-5.3.1 bracex-2.2.1 commonmark-0.9.1 enrich-1.2.6 pygments-2.11.2 rich-10.16.2 ruamel.yaml-0.17.20 ruamel.yaml.clib-0.2.6 tenacity-8.0.1 wcmatch-8.3
```

Then run it on one or more files.

```console
ubuntu@ip-10-8-0-26:~$ ansible-lint fortune-playbook.yml cowsay-playbook.yml
WARNING  Listing 3 violation(s) that are fatal
no-changed-when: Commands should not change things if nothing needs doing
cowsay-playbook.yml:12 Task/Handler: Run fortune

no-changed-when: Commands should not change things if nothing needs doing
cowsay-playbook.yml:22 Task/Handler: Run cowsay

no-changed-when: Commands should not change things if nothing needs doing
fortune-playbook.yml:12 Task/Handler: Run fortune

You can skip specific rules or tags by adding them to your configuration file:
# .ansible-lint
warn_list:  # or 'skip_list' to silence them completely
  - no-changed-when  # Commands should not change things if nothing needs doing

Finished with 3 failure(s), 0 warning(s) on 2 files.
```

In this case, all 3 violations are because we are not *idempotent*- each time we
run the playbook we get a different result. That is the nature of the `fortune`
command and useful for demo purposes, but it is definitely not how we would 
normally use Ansible.

It is critical that when writing "real" playbooks that we make sure we can run
them back-to-back and see no changes the second time. The thinking and planning
sometimes takes some getting used to.

## End of Lesson 06
