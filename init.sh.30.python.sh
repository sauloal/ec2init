#what to install
echo "UPDATING PYTHON"

#boto
easy_install boto
# gives boto-rsync
easy_install boto_rsync
# gives ses-send-email and s3-geturl, among others
easy_install boto_utils

# others
easy_install Flask
easy_install simplejson
easy_install jsonpickle

# zdaemon - http://ridingpython.blogspot.nl/2011/08/turning-your-python-script-into-linux.html
easy_install zdaemon
