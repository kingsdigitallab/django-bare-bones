# -----------------------------------------------------------------------------
# Import the settings here according to the environment. Options are dev, stg,
# and liv.
#
# If a local settings file is present (local.py), it will override the settings
# imported here. Use it for settings specific to the installation and do not
# commit to version control.
# -----------------------------------------------------------------------------
import os
env_path = os.getcwd()

if '/liv/' in env_path:
    from local_liv import *  # noqa
elif '/stg/' in env_path:
    from local_stg import * # noqa
elif '/dev/' in env_path:
    from local_dev import * # noqa
else:
    from local import * # noqa