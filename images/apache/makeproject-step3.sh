#!/bin/bash

set -e

cd $PROJECT_ROOT

# gives $BOINC_USER permission to run Docker commands
#DOCKER_GID=$(stat -c '%g' /var/run/docker.sock)
# Hack to make this work within docker-compose
addgroup -gid 999 docker
addgroup ${BOINC_USER} docker

while :
do
    # the first time we build a project, we wait here until the makeproject-step2.sh
    # script is done
    while [ ! -f .built_${PROJECT} ] ; do sleep 1; done

    echo "Finalizing project startup..."

    # add a new url since the python script doesnt allow custom url except with the awful cgi-bin
    # https://github.com/BOINC/boinc/blob/master/tools/make_project#L351
    perl -i -p0e 's#Alias /minecrafthome /home/boincadm/project/html/user#Alias /minecrafthome/projects /home/boincadm/project/html/new\n    Alias /minecrafthome /home/boincadm/project/html/user#s' minecrafthome.httpd.conf
    perl -i -p0e 's#Alias /minecrafthome /home/boincadm/project/html/user#Alias /projects /home/boincadm/project/html/new\n    Alias /minecrafthome /home/boincadm/project/html/user#s' minecrafthome.httpd.conf
    perl -i -p0e 's#Alias /minecrafthome /home/boincadm/project/html/user#Redirect "/minecrafthome/projects.html" "/projects/list.html"\n    Alias /minecrafthome /home/boincadm/project/html/user#s' minecrafthome.httpd.conf
    perl -i -p0e 's#Alias /minecrafthome /home/boincadm/project/html/user#Redirect "/minecrafthome/all" "/projects/list.html"\n    Alias /minecrafthome /home/boincadm/project/html/user#s' minecrafthome.httpd.conf
    perl -i -p0e 's#Alias /minecrafthome /home/boincadm/project/html/user#Redirect "/minecrafthome/herobrine.html" "/projects/herobrine.html"\n    Alias /minecrafthome /home/boincadm/project/html/user#s' minecrafthome.httpd.conf
    perl -i -p0e 's#Alias /minecrafthome /home/boincadm/project/html/user#Redirect "/minecrafthome/herobrine" "/projects/herobrine.html"\n    Alias /minecrafthome /home/boincadm/project/html/user#s' minecrafthome.httpd.conf
    perl -i -p0e 's#Alias /minecrafthome /home/boincadm/project/html/user#Redirect "/minecrafthome/markiplier" "/projects/markiplier.html"\n    Alias /minecrafthome /home/boincadm/project/html/user#s' minecrafthome.httpd.conf
    perl -i -p0e 's#Alias /minecrafthome /home/boincadm/project/html/user#Redirect "/minecrafthome/markiplier.html" "/projects/markiplier.html"\n    Alias /minecrafthome /home/boincadm/project/html/user#s' minecrafthome.httpd.conf
    perl -i -p0e 's#Alias /minecrafthome /home/boincadm/project/html/user#Redirect "/minecrafthome/beta.html" "/projects/beta-panorama.html"\n    Alias /minecrafthome /home/boincadm/project/html/user#s' minecrafthome.httpd.conf
    perl -i -p0e 's#Alias /minecrafthome /home/boincadm/project/html/user#Redirect "/minecrafthome/beta" "/projects/beta-panorama.html"\n    Alias /minecrafthome /home/boincadm/project/html/user#s' minecrafthome.httpd.conf

    ln -sf ${PROJECT_ROOT}/${PROJECT}.httpd.conf /etc/apache2/sites-enabled/

    # if apache already booted up, restart it so as to reread the httpd.conf
    # file (it could be close as both this script and apache are started at
    # the same time by supervisord, but we need this just in case)
    if ps -C apache2 ; then
        apache2ctl -k graceful
    fi

    # start daemons as $BOINC_USER
    su $BOINC_USER -c """
        bin/start
        (echo "PATH=$PATH"; echo "SHELL=/bin/bash"; cat *.cronjob) | crontab
    """

    echo "Project startup complete."

    # subsequent times we build a project (such as after a PROJECT change), we
    # go through once then possibly go through again to avoid a race condition
    # with makeproject-step2.sh
    inotifywait -e attrib .built_${PROJECT}
done

