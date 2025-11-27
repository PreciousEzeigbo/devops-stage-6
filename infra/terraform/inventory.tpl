[app_servers]
app_server ansible_host=${server_ip} ansible_user=${ssh_user} ansible_ssh_private_key_file=${ssh_private_key}

[app_servers:vars]
domain=${domain}
acme_email=${acme_email}
jwt_secret=${jwt_secret}
github_repo=${github_repo}
github_branch=${github_branch}
ansible_python_interpreter=/usr/bin/python3
