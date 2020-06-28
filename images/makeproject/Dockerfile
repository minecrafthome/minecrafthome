FROM boinc/server_makeproject:4.1.0-b2d@sha256:4f0a3ace09dcd1df90c043f6b52758149eacac19633c39500f74ba3324452a5c

# Copy our version into image
COPY makeproject-step2.sh /usr/local/bin/

# dont need built-in boinc2docker app
RUN rm -rf $PROJECT_ROOT/apps/boinc2docker

COPY --chown=1000 project $PROJECT_ROOT
COPY --chown=1000 secrets.env /run/secrets/
