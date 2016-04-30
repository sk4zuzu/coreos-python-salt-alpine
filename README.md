
Based on `alpine`, simplistic `python27` interpreter with `coreos`-usable `python-salt` installed. 

# BUILD
```
./build.sh --no-cache
```

# PUSH
```
docker push <your-docker-registry>/coreos-python-salt-alpine
```

# RUN
```
docker run --rm -v /opt:/destdir -t <your-docker-registry>/coreos-python-salt-alpine
```

[//]: # ( vim:set ts=4 sw=4 et syn=markdown: )
