# -----------------------------------------------------------------------------
# Imports local settings
# Use it for settings specific to the installation and do not
# commit to version control.
# -----------------------------------------------------------------------------
try:
    from .local import * # noqa
except ImportError:
    # This will occur if we're running under tox
    pass