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

```console
ubuntu@ip-10-8-0-137:~$ ansible-playbook fortune-playbook.yml

PLAY [targets] *********************************************************************************************************************

TASK [Gathering Facts] *************************************************************************************************************
ok: [10.8.0.115]
ok: [10.8.0.128]
ok: [10.8.0.87]

TASK [Install the fortune package] *************************************************************************************************
ok: [10.8.0.115]
ok: [10.8.0.128]
ok: [10.8.0.87]

TASK [Run fortune] *****************************************************************************************************************
changed: [10.8.0.115]
changed: [10.8.0.128]
changed: [10.8.0.87]

TASK [Display fortune results] *****************************************************************************************************
ok: [10.8.0.87] => {
    "fortune_out.stdout": "Your lucky number has been disconnected."
}
ok: [10.8.0.115] => {
    "fortune_out.stdout": "You have many friends and very few living enemies."
}
ok: [10.8.0.128] => {
    "fortune_out.stdout": "Your society will be sought by people of taste and refinement."
}

PLAY RECAP *************************************************************************************************************************
10.8.0.115                 : ok=4    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
10.8.0.128                 : ok=4    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
10.8.0.87                  : ok=4    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
```

We can extend the example to use additional packages as well.

Copying
[cowsay-playbook.yml](./fortune-playbook.yml) to the control node and run it as
a playbook.

```console
ubuntu@ip-10-8-0-137:~$ ansible-playbook cowsay-playbook.yml

PLAY [targets] *********************************************************************************************************************

TASK [Gathering Facts] *************************************************************************************************************
ok: [10.8.0.115]
ok: [10.8.0.87]
ok: [10.8.0.128]

TASK [Install the fortune package] *************************************************************************************************
ok: [10.8.0.115]
ok: [10.8.0.87]
ok: [10.8.0.128]

TASK [Run fortune] *****************************************************************************************************************
changed: [10.8.0.115]
changed: [10.8.0.87]
changed: [10.8.0.128]

TASK [Install the cowsay package] **************************************************************************************************
changed: [10.8.0.115]
changed: [10.8.0.87]
changed: [10.8.0.128]

TASK [Run cowsay] ******************************************************************************************************************
changed: [10.8.0.115]
changed: [10.8.0.87]
changed: [10.8.0.128]

TASK [Display cowsay results] ******************************************************************************************************
ok: [10.8.0.87] => {
    "cowsay_out.stdout_lines": [
        " ____________________________________",
        "/ ip-10-8-0-87: A horse! A horse! My \\",
        "| kingdom for a horse!               |",
        "|                                    |",
        "\\ -- Wm. Shakespeare, Richard III    /",
        " ------------------------------------",
        "        \\   ^__^",
        "         \\  (oo)\\_______",
        "            (__)\\       )\\/\\",
        "                ||----w |",
        "                ||     ||"
    ]
}
ok: [10.8.0.115] => {
    "cowsay_out.stdout_lines": [
        " _________________________________________",
        "/ ip-10-8-0-115: Q: Why do ducks have big \\",
        "| flat feet? A: To stamp out forest       |",
        "| fires.                                  |",
        "|                                         |",
        "| Q: Why do elephants have big flat feet? |",
        "\\ A: To stamp out flaming ducks.          /",
        " -----------------------------------------",
        "        \\   ^__^",
        "         \\  (oo)\\_______",
        "            (__)\\       )\\/\\",
        "                ||----w |",
        "                ||     ||"
    ]
}
ok: [10.8.0.128] => {
    "cowsay_out.stdout_lines": [
        " _________________________________________",
        "/ ip-10-8-0-128: Q: Why do mountain       \\",
        "| climbers rope themselves together? A:   |",
        "| To prevent the sensible ones from going |",
        "\\ home.                                   /",
        " -----------------------------------------",
        "        \\   ^__^",
        "         \\  (oo)\\_______",
        "            (__)\\       )\\/\\",
        "                ||----w |",
        "                ||     ||"
    ]
}

PLAY RECAP *************************************************************************************************************************
10.8.0.115                 : ok=6    changed=3    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
10.8.0.128                 : ok=6    changed=3    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
10.8.0.87                  : ok=6    changed=3    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
```

The `ansible_hostname` comes from the implicit `Gathering Facts` task. You can see
what information Ansible knows for a host using the `setup` module.

```console
ubuntu@ip-10-8-0-137:~$ ansible 10.8.0.115 -m setup | less
10.8.0.115 | SUCCESS => {
    "ansible_facts": {
        "ansible_all_ipv4_addresses": [
            "10.8.0.115"
        ],
...
    "changed": false
}
```

The `{{ }}` notation is a [Jinja2 expression](https://docs.ansible.com/ansible/latest/user_guide/playbooks_templating.html)
that can be used in variables or templates.

## Ansible Lint

Just as we checked our Terraform code with TFLint and Checkov, we can check our
Ansible playbooks for recommended practices using
[Ansible Lint](https://ansible-lint.readthedocs.io/).

Install Ansible Lint on the control node using `pip3`.

```console
ubuntu@ip-10-8-0-137:~$ pip3 install --user "ansible-lint[yamllint]"
Collecting ansible-lint[yamllint]
  Downloading ansible_lint-5.3.1-py3-none-any.whl (114 kB)
...
Successfully installed ansible-lint-5.3.1 bracex-2.2.1 commonmark-0.9.1 enrich-1.2.6 pathspec-0.9.0 pygments-2.11.1
rich-10.16.2 ruamel.yaml-0.17.20 ruamel.yaml.clib-0.2.6 tenacity-8.0.1 wcmatch-8.3 yamllint-1.26.3
```

Then run it on one or more files.

```console
ubuntu@ip-10-8-0-137:~$ ansible-lint fortune-playbook.yml cowsay-playbook.yml
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

In this case, all 3 violations are because we are not idempotent- each time we
run the playbook we get a different result. That is the nature of the `fortune`
command, and useful for demo purposes, but it is definitely not how we normally
would use Ansible.

It is critical that when writing "real" playbooks that we make sure we can run
them back-to-back and see no changes the second time. It sometimes takes some
getting used to.

## End of Lesson 06
