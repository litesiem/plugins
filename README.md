# LiteSIEM client

Sample fluentbit client configs/parsers for LiteSIEM.

## Getting started

```sh
# update fluentbit/conf/fluent-bit.conf
# map the correct volumes in docker-compose.yaml
docker compose up

go install github.com/mingrammer/flog@latest
make flog
```

## Clients

| plugin       | cfg? | id   | rules? |
| ------------ | ---- | ---- | ------ |
| apache       | x    | 1501 |        |
| iis          | x    | 1502 |        |
| iptables     | x    | 1503 |        |
| oracle       | x    | 1651 |        |
| ssh          | x    | 4003 | x      |
| sudo         | x    | 4005 |        |
| syslog       | x    | 4007 |        |
| mysql        | ?    |      |        |
| systemd      | ?    |      |        |
| winlog       | ?    |      |        |
| winlog       | ?    |      |        |
| postgres     | ?    |      |        |
| mssql-server | ?    |      |        |
| nginx        | -    |      |        |
