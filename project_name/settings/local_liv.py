from .base import *  # noqa

ALLOWED_HOSTS = ['$PROJECT_NAME.kdl.kcl.ac.uk']

INTERNAL_IPS = INTERNAL_IPS + ['']

DATABASES = {
    'default': {
        'ENGINE': db_engine,
        'NAME': 'app_$PROJECT_NAME_liv',
        'USER': 'app_$PROJECT_NAME',
        'PASSWORD': '',
        'HOST': ''
    },
}

SECRET_KEY = ''
