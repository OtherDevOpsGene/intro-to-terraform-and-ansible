# Lesson 06 - Playbook basics

*Except where noted, these instructions should be run on the Ansible workstation
(i.e., control node) we stood up in [Lesson 04](../lesson-04/README.md).
Run that lesson now, if needed.*

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
- name: Fortune cookies
  hosts: targets

  tasks:
    - name: Install the fortune package
      ansible.builtin.apt:
        name: fortune
        state: present
        update_cache: true
      become: true

    - name: Run fortune
      ansible.builtin.command: fortune
      register: fortune_out

    - name: Display fortune results
      ansible.builtin.debug:
        var: fortune_out.stdout
```

```console
ubuntu@ip-10-8-0-26:~$ ansible-playbook fortune-playbook.yml

PLAY [Fortune cookies] *************************************************************************************************************

TASK [Gathering Facts] *************************************************************************************************************
ok: [10.8.0.178]
ok: [10.8.0.10]
ok: [10.8.0.41]

TASK [Install the fortune package] *************************************************************************************************
ok: [10.8.0.10]
ok: [10.8.0.178]
ok: [10.8.0.41]

TASK [Run fortune] *****************************************************************************************************************
changed: [10.8.0.178]
changed: [10.8.0.10]
changed: [10.8.0.41]

TASK [Display fortune results] *****************************************************************************************************
ok: [10.8.0.10] => {
    "fortune_out.stdout": "Q:\tWhat do you get when you cross the Godfather with an attorney?\nA:\tAn offer you can't understand."
}
ok: [10.8.0.41] => {
    "fortune_out.stdout": "Good news.  Ten weeks from Friday will be a pretty good day."
}
ok: [10.8.0.178] => {
    "fortune_out.stdout": "Q:\tWhat lies on the bottom of the ocean and twitches?\nA:\tA nervous wreck."
}

PLAY RECAP *************************************************************************************************************************
10.8.0.10                  : ok=4    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
10.8.0.178                 : ok=4    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
10.8.0.41                  : ok=4    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0

```

We can extend the example to use additional packages as well.

Copy
[cowsay-playbook.yml](./fortune-playbook.yml) to the control node and run it as
a playbook.

```yaml
---
- name: Cows telling fortunes
  hosts: targets

  tasks:
    - name: Install the fortune package
      ansible.builtin.apt:
        name: fortune
        state: present
        update_cache: true
      become: true

    - name: Run fortune
      ansible.builtin.command: fortune
      register: fortune_out

    - name: Install the cowsay package
      ansible.builtin.apt:
        name: cowsay
        state: present
      become: true

    - name: Run cowsay
      ansible.builtin.command: "cowsay \"{{ ansible_hostname }}: {{ fortune_out.stdout }}\""
      register: cowsay_out

    - name: Display cowsay results
      ansible.builtin.debug:
        var: cowsay_out.stdout_lines
```

```console
ubuntu@ip-10-8-0-26:~$ ansible-playbook cowsay-playbook.yml

PLAY [Cows telling fortunes] *******************************************************************************************************

TASK [Gathering Facts] *************************************************************************************************************
ok: [10.8.0.10]
ok: [10.8.0.178]
ok: [10.8.0.41]

TASK [Install the fortune package] *************************************************************************************************
ok: [10.8.0.178]
ok: [10.8.0.10]
ok: [10.8.0.41]

TASK [Run fortune] *****************************************************************************************************************
changed: [10.8.0.178]
changed: [10.8.0.10]
changed: [10.8.0.41]

TASK [Install the cowsay package] **************************************************************************************************
changed: [10.8.0.178]
changed: [10.8.0.10]
changed: [10.8.0.41]

TASK [Run cowsay] ******************************************************************************************************************
changed: [10.8.0.10]
changed: [10.8.0.178]
changed: [10.8.0.41]

TASK [Display cowsay results] ******************************************************************************************************
ok: [10.8.0.10] => {
    "cowsay_out.stdout_lines": [
        " _______________________________________",
        "/ ip-10-8-0-10: You will win success in \\",
        "\\ whatever calling you adopt.           /",
        " ---------------------------------------",
        "        \\   ^__^",
        "         \\  (oo)\\_______",
        "            (__)\\       )\\/\\",
        "                ||----w |",
        "                ||     ||"
    ]
}
ok: [10.8.0.41] => {
    "cowsay_out.stdout_lines": [
        " _______________________________________",
        "/ ip-10-8-0-41: You'll feel much better \\",
        "\\ once you've given up hope.            /",
        " ---------------------------------------",
        "        \\   ^__^",
        "         \\  (oo)\\_______",
        "            (__)\\       )\\/\\",
        "                ||----w |",
        "                ||     ||"
    ]
}
ok: [10.8.0.178] => {
    "cowsay_out.stdout_lines": [
        " ________________________________________",
        "/ ip-10-8-0-178: You will be run over by \\",
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
10.8.0.10                  : ok=6    changed=3    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
10.8.0.178                 : ok=6    changed=3    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
10.8.0.41                  : ok=6    changed=3    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
```

The `ansible_hostname` comes from the implicit `Gathering Facts` task. We can see
what information Ansible knows for a host using the `setup` module.

```console
ubuntu@ip-10-8-0-26:~$ ansible 10.8.0.41 -m setup | less
10.8.0.41 | SUCCESS => {
    "ansible_facts": {
...
        "ansible_hostname": "ip-10-8-0-41",
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
  Downloading ansible_lint-6.17.0-py3-none-any.whl (278 kB)
...
Installing collected packages: tomli, subprocess-tee, ruamel.yaml.clib, pygments, platformdirs, pathspec, mypy-extensions, mdurl, jsonschema, filelock, bracex, yamllint, wcmatch, ruamel.yaml, markdown-it-py, black, ansible-compat, rich, ansible-lint
Successfully installed ansible-compat-4.1.2 ansible-lint-6.17.0 black-23.3.0 bracex-2.3.post1 filelock-3.12.1 jsonschema-4.17.3 markdown-it-py-2.2.0 mdurl-0.1.2 mypy-extensions-1.0.0 pathspec-0.11.1 platformdirs-3.5.3 pygments-2.15.1 rich-13.4.1 ruamel.yaml-0.17.31 ruamel.yaml.clib-0.2.7 subprocess-tee-0.4.1 tomli-2.0.1 wcmatch-8.4.1 yamllint-1.32.0
```

Then run it on one or more files.

```console
ubuntu@ip-10-8-0-26:~$ ansible-lint fortune-playbook.yml cowsay-playbook.yml
WARNING  Listing 3 violation(s) that are fatal
no-changed-when: Commands should not change things if nothing needs doing.
cowsay-playbook.yml:13 Task/Handler: Run fortune

no-changed-when: Commands should not change things if nothing needs doing.
cowsay-playbook.yml:23 Task/Handler: Run cowsay

no-changed-when: Commands should not change things if nothing needs doing.
fortune-playbook.yml:13 Task/Handler: Run fortune

Read documentation for instructions on how to ignore specific rule violations.

                  Rule Violation Summary                  
 count tag             profile rule associated tags       
     3 no-changed-when shared  command-shell, idempotency 

Failed after safety profile, 3/5 star rating: 3 failure(s), 0 warning(s) on 2 files.
```

In this case, all 3 violations are because we are not *idempotent*- each time we
run the playbook we get a different result. That is the nature of the `fortune`
command and useful for demo purposes, but it is definitely not how we would
normally use Ansible.

It is critical that when writing "real" playbooks that we make sure we can run
them back-to-back and see no changes the second time. The thinking and planning
sometimes takes some getting used to.

## End of Lesson 06

In the next lesson, we'll use Ansible to do something
[a little more practical](../lesson-07/README.md).
