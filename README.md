![](https://raw.githubusercontent.com/minecrafthome/branding/master/social/github-readme.png)

Minecraft@Home BOINC
====================

## Volunteer your compute resources

You can volunteer your compute resources to help with our research, BOINC will use your computer when you're not to run applications which further our research.

[Click here to join!](https://minecraftathome.com/minecrafthome/signup.php)

## Development

The [Minecraft@Home](https://minecraftathome.com) server is a set of [Docker](https://docker.com) containers which together create a [BOINC](https://boinc.berkeley.edu/) environment to allow the public to volunteer compute resources for use with Minecraft research projects.

Using a few commands, anyone can check out this code and run a local version of the Minecraft@Home server _(identical to the live deployment excluding user data and secret material)_. 

The requirements for running the server are:
* [docker](https://docs.docker.com/engine/installation/)
* [docker-compose](https://docs.docker.com/compose/install/)

To download, build, and start the server:
```Change config.xml 'dbuser' property to your MySQL/MariaDB default user (usually root).
Change docker-compose.yml and .env to use your domain and certificate.```

```bash
git clone --recursive https://github.com/minecrafthome/minecrafthome.git
cd minecrafthome
docker-compose up -d
```

At this point, you should be able to visit [localhost](http://localhost:80/minecrafthome) from your browser to see the server webpage. You may also connect BOINC client to this local server using the same URL.
