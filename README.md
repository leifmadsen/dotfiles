# dotfiles

Configuration files found in the home directory.

## Installation
You can install this with Ansible using the local connector with the following command. Just update the `hosts` file before you run the command so that you don't install it into my home directory :)


```
ansible-playbook -c local -i hosts dotfiles.yml
```