![](https://raw.githubusercontent.com/minecrafthome/branding/master/social/github-readme.png)

The Minecraft@Home server
=========================

The [Minecraft@Home](https://minecraftathome.com) server is a set of [Docker](https://docker.com) containers which together create a [BOINC](https://boinc.berkeley.edu/) environment to allow the public to volunteer compute resources for use with Minecraft research projects.

Using a few commands, anyone can check out this code and run a local version of the Minecraft@Home server _(identical to the live deployment excluding user data and secret material)_. 

The requirements for running the server are:
* [docker](https://docs.docker.com/engine/installation/)
* [docker-compose](https://docs.docker.com/compose/install/)

To download, build, and start the server:

```bash
git clone --recursive https://github.com/minecrafthome/minecrafthome.git
cd minecrafthome
docker-compose up -d
```

At this point, you should be able to visit [localhost](http://localhost:80/minecrafthome) from your browser to see the server webpage. You may also connect BOINC client to this local server using the same URL.
