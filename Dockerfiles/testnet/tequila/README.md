# Terra Validator node

This dockerfile generates an image with a Tequila node ready to go.
Tequila-0004 is the testnet related to the columbus-4 mainnet, bombay-0008 is related to the n+1 columbus-5 version

### How to use
```
# checkout and cd to the directory
# change the MONIKER and optionally the USER variables (multiple occurences)
# then build the image:
$ docker build --tag=terrad_tequila_01:v1 .

# to run it, use 
$ docker run -d --name terrad-tequila-01 -p 27657:26657 --mount source=terrad-data,target=/home/terra/.terrad/data terrad_tequila_01:v1
```

Argument `--mount` is important and maps the directory `.terrad/data` to your host, so when destroying/recreating the container the data is persistent.
Port number is binded to 27657 to prevent conflicts with other nodes, if present

Be aware that tequila-0004 node needs about 200Go of space right now (08/2021) and grows slowly.

### Remaing steps

None. The node will start downloading blocks and catching up, it can take some hours.
You can check the logs to get the current height and paste it on https://tequila.stake.id/#/ 

If you have terracli installed on the host, check the `catching_up` flag from the query `terracli --node tcp://localhost:27657 status | jq`