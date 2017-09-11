from .base import *  # noqa

INTERNAL_IPS = INTERNAL_IPS + ['']
ALLOWED_HOSTS = ['']

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
