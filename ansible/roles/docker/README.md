# Docker role
> [!WARNING]
> This role works on **Ubuntu** and **Debian** (apt repo URI follows the distro).

Role to set up Docker and needed tools.

Actions:
* install Docker
* allow as non-root
* have Docker start on boot using **systemctl**
* enable log rotation to avoid clogging the disk

## Post-installation steps
* Log out to update the group membership
* Test your install with `docker run hello-world`


## Troubleshooting
### Permission issue
```Shell
$ docker run hello-world

WARNING: Error loading config file: /home/user/.docker/config.json -
stat /home/user/.docker/config.json: permission denied
```

To fix this problem, either remove the ~/.docker/ directory (it's recreated automatically, but any custom settings are lost), or change its ownership and permissions using the following commands:

```Shell
sudo chown "$USER":"$USER" /home/"$USER"/.docker -R
sudo chmod g+rwx "$HOME/.docker" -R
```



## Sources
Heavily inspired from Docker docs:
- [https://docs.docker.com/engine/install/ubuntu/]()
- [https://docs.docker.com/engine/install/linux-postinstall/]()