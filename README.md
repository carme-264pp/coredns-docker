# coredns-docker

## How to use

1. build

   ```shell
   docker compose build
   ```

2. configure coredns

    ```shell
    cp config/Corefile.example config/Corefile
    ```

3. Run

    ```shell
    docker compose up -d
    ```
