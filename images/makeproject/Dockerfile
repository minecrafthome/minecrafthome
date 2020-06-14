FROM boinc/server_makeproject:4.0.1-b2d@sha256:fc3ffb9dfcb01e47146056ef47d400d1b237b3f561a606f6d441fbca27999427

# Copy our version into image
COPY makeproject-step2.sh /usr/local/bin/

# dont need built-in boinc2docker app
RUN rm -rf $PROJECT_ROOT/apps/boinc2docker

COPY --chown=1000 config.xml project.xml plan_class_spec.xml $PROJECT_ROOT/
COPY --chown=1000 project_files $PROJECT_ROOT
