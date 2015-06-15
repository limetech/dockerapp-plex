This is a Dockerfile setup for plex with plexpass - http://plex.tv/

To run the latest plexpass version:

```
docker run -d --net="host" --name="plex" -v /path/to/plex/config:/config -v /path/to/video/files:/data -v /etc/localtime:/etc/localtime:ro limetech/plex
```

After install go to:

http://server:32400/web/index.html#!/dashboard and login with your myPlex credentials
