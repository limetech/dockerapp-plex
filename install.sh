#!/bin/bash

# chfn workaround - Known issue within Dockers
ln -s -f /bin/true /usr/bin/chfn

apt-get -q update
apt-get install -qy gdebi-core wget

# Plex version 1.18.9.2571-e106a8a91
PLEX_URL=$(curl -sL https://plex.tv/api/downloads/1.json | sed -nr 's#.*"url":"([^"]+?debian\/plexmediaserver_[^"]+?_amd64\.deb)".*#\1#p')
PLEX_VERSION=$(echo $PLEX_URL | awk -F_ '{print $2}')

wget -q "$PLEX_URL" -O /tmp/plexmediaserver_${PLEX_VERSION}_amd64.deb
if [ $? -eq 0 ]; then
    gdebi -n /tmp/plexmediaserver_${PLEX_VERSION}_amd64.deb
    rm -f /tmp/plexmediaserver_${PLEX_VERSION}_amd64.deb
    echo $PLEX_VERSION > /tmp/version
fi

# Fix a Debianism of plex's uid being 101
usermod -u 99 plex
usermod -g 100 plex

# Add Plex to runit
mkdir -p /etc/service/plex
cat <<'EOT' > /etc/service/plex/run
#!/bin/bash
umask 000

# Fix permission if user is 999
if [ -d /config/Library ]; then
	if [ "$(stat -c "%u" /config/Library/)" -eq "999" ]; then
		echo "Fixing Plex Library permissions"
		chown -R 99:100 /config/Library/
		chmod -R 777 /config/Library/
	fi
fi

# Create library and transcode tmp folders if needed
mkdir -p /config/tmp "/config/Library/Application Support"
chown 99:100 /config/tmp /config/Library "/config/Library/Application Support"
chmod 777 /config/tmp /config/Library "/config/Library/Application Support"

exec /sbin/setuser plex /usr/sbin/start_pms
EOT
chmod +x /etc/service/plex/run
