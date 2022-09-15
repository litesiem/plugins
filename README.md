# LiteSIEM client

Sample fluentbit client configs/parsers for LiteSIEM.

Fake logs are generated using [flog](https://github.com/mingrammer/flog).

[Default](https://github.com/fluent/fluent-bit/blob/master/conf/parsers.conf)/[extra](https://github.com/fluent/fluent-bit/tree/master/conf) fluentbit parsers.

## TODO
- [ ] Read new events only
- [ ] `Expect` keys to exclude malformed events 
- [ ] Add `http_out` HTTP Basic Auth

## Supported clients
### OS
- [x] Linux - systemd
- [x] Windows - winlog/winevtlog

### Server
- [x] Apache - `access.log`
- [x] Nginx
- [ ] MS IIS
  
### DBMS
- [x] MySQL - `error.log`
- [x] Postgres
- [ ] MS SQL Server

## Development

- Demo:
  ```sh
  timeout 10s make flog
  ```

### Local installation

```sh
# Debian
/opt/fluent-bit/bin/fluent-bit -c /etc/fluent-bit/fluent-bit.conf

# Windows
fluent-bit -i winevtlog -p 'channels=Setup' -o stdout
```

## DB Logs

Types: access log, audit log?, error log

### MSSQL

To enable connection logging, use SQL Server Management Studio. See [[1]](https://stackoverflow.com/a/6769173/6567303), [[2]](https://dba.stackexchange.com/a/258380), [docs](https://docs.microsoft.com/en-us/sql/ssms/configure-login-auditing-sql-server-management-studio?view=sql-server-ver16). Connection logs will be in error log. It is not immediately obvious if the same can be done using the cross platform Azure Data Studio.

### MySQL

[Docs](https://dev.mysql.com/doc/refman/5.7/en/server-logs.html)

### Postgres

Default postgres log location is stderr. To configure logging see [docs](https://www.postgresql.org/docs/current/runtime-config-logging.html) or [this guide](https://www.enterprisedb.com/blog/how-get-best-out-postgresql-logs).

[Default config](https://gist.github.com/64kramsystem/d780ce0f8dff7b90847b2728f506cdea)

Channels - stderr, csvlog, syslog, eventlog \
[Fields](https://www.postgresql.org/docs/current/runtime-config-logging.html#GUC-LOG-LINE-PREFIX) \
[csvlog fields](https://www.postgresql.org/docs/current/runtime-config-logging.html#RUNTIME-CONFIG-LOGGING-CSVLOG) 


> **Warning**
> fluent-bit does not support parsing csv files yet! See [issue on GH](https://github.com/fluent/fluent-bit/issues/459).

> **Warning**
> The PostgreSQL data directory (tree) is owned by `postgres` with permissions `700` 


```sh  
# or sudo -u postgres psql -c ''
psql -U postgres -c 'SHOW data_directory'
psql -U postgres -c 'SHOW config_file'
```

Sample conf:
```
log_statement = mod
log_connections = 1
log_disconnections = 0
log_file_mode = 0644
log_min_duration_statement = 1000 # ms
log_min_error_statement = ERROR # DEBUG1...INFO, NOTICE, WARNING, ERROR, LOG, FATAL, PANIC
```
