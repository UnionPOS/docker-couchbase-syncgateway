FROM unionpos/ubuntu:16.04

ENV PATH $PATH:/opt/couchbase-sync-gateway/bin

ARG SYNC_VERSION=2.5.0
ARG SYNC_RELEASE_URL=https://packages.couchbase.com/releases/couchbase-sync-gateway
ARG SYNC_PACKAGE="couchbase-sync-gateway-enterprise_2.5.0_x86_64.deb"

# Install Sync Gateway
RUN set -ex \
	&& buildDeps=' \
	wget \
	' \
	&& apt-get update \
	&& apt-get install -y --no-install-recommends $buildDeps \
	&& wget $SYNC_RELEASE_URL/$SYNC_VERSION/$SYNC_PACKAGE \
	&& apt-get purge -y --auto-remove $buildDeps \
	&& rm -rf /var/lib/apt/lists/* \
	&& dpkg --unpack $SYNC_PACKAGE \
	&& rm -f $SYNC_PACKAGE

# Create directory where the default config stores memory snapshots to disk
RUN mkdir /opt/couchbase-sync-gateway/data

# copy the default config into the container
COPY config/sync_gateway_config.json /etc/sync_gateway/config.json

# create directory for seeding database
RUN mkdir /docker-entrypoint-initdb.d

# Add bootstrap script
COPY scripts/docker-entrypoint.sh /usr/local/bin/
ENTRYPOINT ["docker-entrypoint.sh"]

# If user doesn't specify any args, use the default config
CMD ["/etc/sync_gateway/config.json"]

# Expose ports
#  port 4984: public port
#  port 4985: admin port
# EXPOSE 4984 4985
