FROM ubuntu:26.04

# Install dependencies
RUN apt-get update &&     apt-get install -y --no-install-recommends     ca-certificates     libcurl4     openssl     && rm -rf /var/lib/apt/lists/*

# Create bedrock user and group
RUN groupadd -r bedrock && useradd -r -g bedrock -u 999 bedrock

# Create directories
RUN mkdir -p /bedrock/worlds /bedrock/config &&     chown -R bedrock:bedrock /bedrock

WORKDIR /bedrock

# Copy server files
COPY --chown=bedrock:bedrock bedrock_server /bedrock/
COPY --chown=bedrock:bedrock behavior_packs /bedrock/behavior_packs
COPY --chown=bedrock:bedrock definitions /bedrock/definitions
COPY --chown=bedrock:bedrock resource_packs /bedrock/resource_packs
COPY --chown=bedrock:bedrock config /bedrock/config

# Copy configuration files
COPY --chown=bedrock:bedrock server.properties /bedrock/
COPY --chown=bedrock:bedrock allowlist.json /bedrock/
COPY --chown=bedrock:bedrock permissions.json /bedrock/
COPY --chown=bedrock:bedrock packetlimitconfig.json /bedrock/
COPY --chown=bedrock:bedrock profanity_filter.wlist /bedrock/

# Make bedrock_server executable
RUN chmod +x /bedrock/bedrock_server

# Switch to bedrock user
USER bedrock

# Expose ports
EXPOSE 19132/udp 19133/udp

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3   CMD pgrep -x bedrock_server || exit 1

# Start server
ENTRYPOINT ["/bedrock/bedrock_server"]
