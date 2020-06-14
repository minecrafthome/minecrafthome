FROM boinc/server_makeproject:4.0.1-b2d

# Copy our version into image
COPY makeproject-step2.sh /usr/local/bin/

# dont need built-in boinc2docker app
RUN rm -rf $PROJECT_ROOT/apps/boinc2docker

COPY --chown=1000 config.xml project.xml plan_class_spec.xml $PROJECT_ROOT/
COPY --chown=1000 project_files $PROJECT_ROOT
COPY --chown=1000 html/project/project.inc $PROJECT_ROOT/html/project/
