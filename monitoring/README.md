# Oracle watcher script

This script checks that the votes are correctly submitted, and in case it's not it restarts the service.

## How to

Adapt it following your needs.
Current configuration is `systemctl`.

###Systemctl service config:


```
$ cat /etc/systemd/system/terrad-price-feeder-watcher.service
[Unit]
Description=Terra Price Watcher
Requisite=network-online.target
After=network-online.target

[Service]
Type=simple
ExecStart=/home/terra/terrad-scripts/monitoring/oracle-monitoring.sh your_terravaloper_address "https://lcd.terra.dev"
Restart=always
User=terra

[Install]
WantedBy=multi-user.target
```

Reload systemd:
`systemctl daemon-reload`
Start on boot;
`systemctl enable terrad-price-feeder-watcher.service`

###sudoers config:

For the script to be able to restart the oracle feeder without being run as root nor asking for password, you need to add the following:

```
$ cat /etc/sudoers.d/terra
terra ALL=NOPASSWD: /usr/bin/systemctl restart terrad-price-feeder

```
(or the line for upstart if required)

In case you break the sudo command (for exemple by forgetting the blank line at the end of the file), see https://askubuntu.com/questions/73864/how-to-modify-an-invalid-etc-sudoers-file


#### Contact

For any question find use on Terra Discord server.