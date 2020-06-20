#!/bin/bash

set -e

source /run/secrets/secrets.env

PROJECT_ROOT_DEST=$PROJECT_ROOT.dst
cd $PROJECT_ROOT

echo "Updating project files in data volume..."

# do variable substitution in files
for file in config.xml html/user/schedulers.txt *.httpd.conf html/project/project.inc; do 
    sed -i -e "s|\${PROJECT}|$PROJECT|gI" \
           -e "s|REPLACE WITH PROJECT NAME|$PROJECT|gI" \
           -e "s|\${PROJECT_ROOT}|$PROJECT_ROOT|gI" \
           -e "s|\${URL_BASE}|$URL_BASE|gI" \
           -e "s|\${DB_PASSWD}|$DB_PASSWD|gI" \
           -e "s|\${MAILPASS}|$MAILPASS|gI" \
           -e "s|\${RECAPTCHA_PUBLIC_KEY}|$RECAPTCHA_PUBLIC_KEY|gI" \
           -e "s|\${RECAPTCHA_PRIVATE_KEY}|$RECAPTCHA_PRIVATE_KEY|gI" \
        $file
done
# do variable substitution in file names (although with -n to not overwrite
# existing files which may be customized versions provided by the project)
for file in \$\{project\}*; do
    mv -n $file ${file/\$\{project\}/$PROJECT}
    rm -f $file
done

# copy files
cp -rfT --preserve=mode,ownership $PROJECT_ROOT $PROJECT_ROOT_DEST
mv $PROJECT_ROOT ${PROJECT_ROOT}.orig
ln -s $PROJECT_ROOT_DEST $PROJECT_ROOT
cd $PROJECT_ROOT


# wait for MySQL server to start
echo "Waiting for MySQL server to start..."
if ! timeout -s KILL 60 mysqladmin ping -h mysql --wait &> /dev/null ; then
    echo "MySQL server failed to start after 60 seconds. Aborting."
    exit 1
fi


# if we can get in the root MySQL account without password, it means this is the
# first run after project creation, in which case set the password, and create
# the project database
if mysql -u root -e "" &> /dev/null ; then
    echo "Creating database..."
    mysqladmin -h mysql -u root password $DB_PASSWD
    PYTHONPATH=/usr/local/boinc/py python -c """if 1:
        from Boinc import database, configxml
        database.create_database(srcdir='/usr/local/boinc',
                                 config=configxml.ConfigFile(filename='$PROJECT_ROOT/config.xml').read().config,
                                 drop_first=False)
    """

fi

(cd html/ops && ./db_schemaversion.php > ${PROJECT_ROOT}/db_revision)

bin/xadd
yes | bin/update_versions

# Add the template work units
#bin/create_work --appname kaktwoos --wu_template templates/test_in --result_template templates/test_out -wu_name test_nodelete
#bin/create_work --appname kaktwoos --wu_template templates/main_in --result_template templates/main_out -wu_name main_nodelete

#for i in {0..100}; do while read line; do #2817 in prod
#  wu_name="$(printf "%04d\n" $i)_$(echo $line | cut -d' ' -f1)"
#  echo "create_work: ${wu_name}"
#  bin/create_work --appname kaktwoos \
#    --wu_template templates/seeds_in \
#    --result_template templates/seeds_out \
#    --command_line "${i}00000000000 $((i + 1))00000000000 $line" \
#    --wu_name "${wu_name}"
#done <<< "$(cat seeds.txt | cut -d' ' -f1-6)"; done

i=0
while [ $i -lt 524300 ]; do
  bin/create_work --appname panorama \
    --wu_template templates/seeds_in \
    --result_template templates/seeds_out \
    --command_line "$i $((i + 500))" \
    --wu_name "pano_1.01_$i"; i=$((i + 500))
done

touch $PROJECT_ROOT/.built_${PROJECT}
