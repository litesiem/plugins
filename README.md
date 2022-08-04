## LiteSIEM client

Sample fluentbit client configs/parsers for LiteSIEM.

## Networking

- Accessing localhost from inside container: `host.docker.internal` with 
    ```
    extra_hosts:
      - "host.docker.internal:host-gateway"
    ```
- For fluentbit client without docker: `localhost` or specific IP e.g. `192.168.0.1`
