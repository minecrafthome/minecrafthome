FROM boinc/server_apache:4.1.0-b2d@sha256:ed9e0e914bdc917b76da1cd1c246b9e492b3474108c96265dfdac15384fa43df

COPY --chown=1000 makeproject-step3.sh /usr/bin

# Install additional dependencies
RUN apt-get update && apt-get install -y \
    python-mysqldb \
	tree \
 && rm -rf /var/lib/apt/lists/* \
 && apt-get clean
