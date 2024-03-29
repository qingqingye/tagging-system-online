from .settings_base import *
import os

# Settings for Imagetagger
# Copy this file as settings.py and customise as necessary

# SECURITY WARNING: keep the secret key used in production secret!
SECRET_KEY = 'FDB123456'

# SECURITY WARNING: don't run with debug turned on in production!
DEBUG = True

# Allowed Host headers this site can server
ALLOWED_HOSTS = ['*']

# Additional installed apps
INSTALLED_APPS +=[]

# Database
# https://docs.djangoproject.com/en/1.10/ref/settings/#databases

DATABASES = {
    'default': {
        # Imagetagger relies on some Postgres features so other Databses will _not_ work
        'ENGINE': 'django.db.backends.postgresql_psycopg2',
        'HOST': '127.0.0.1',
        'NAME': 'postgres',
        'PASSWORD': '123456',
        'USER': 'postgres',
    }
}


# DATABASES = {
#     'default': {
#         'ENGINE': 'django.db.backends.mysql',
#         'NAME': 'tagging',
#         'USER': 'root',
#         'PASSWORD':'123456',
#         'HOST':'localhost',
#         'PORT':'3306'
#     }
# }


# Internationalization
# https://docs.djangoproject.com/en/1.10/topics/i18n/

LANGUAGE_CODE = 'en-us'

# TIME_ZONE = 'Europe/Berlin' #Timezone of your server

# STATIC_URL = '/static/'

# EXPORT_SEPARATOR = '|'
# DATA_PATH = os.path.join(BASE_DIR, 'data')

# IMAGE_PATH = os.path.join(BASE_DIR, 'images')  # the absolute path to the folder with the imagesets

# filename extension of accepted imagefiles
# IMAGE_EXTENSION = {
#     'png',
#     'jpg',
# }

USE_NGINX_IMAGE_PROVISION = False  # defines if images get provided directly via nginx what generally improves imageset download performance

# The 'report a problem' page on an internal server error can either be a custom url or a text that can be defined here.
# PROBLEMS_URL = 'https://problems.example.com'
# PROBLEMS_TEXT = 'To report a problem, contact admin@example.com'

USE_IMPRINT = False
IMPRINT_NAME = ''
IMPRINT_URL = ''
UPLOAD_NOTICE = 'By uploading images to this tool you accept that the images get published under creative commons license and confirm that you have the permission to do so.'

DOWNLOAD_BASE_URL = ''  # the URL where the ImageTagger is hosted e.g. https://imagetagger.bit-bots.de

ACCOUNT_ACTIVATION_DAYS = 7

UPLOAD_FS_GROUP = 33  # www-data on debian

ENABLE_ZIP_DOWNLOAD = False  # If enabled, run manage.py runzipdaemon to create the zip files and keep them up to date

# Test mail functionality by printing mails to console:
#EMAIL_BACKEND = 'django.core.mail.backends.console.EmailBackend'

EMAIL_BACKEND='django.core.mail.backends.smtp.EmailBackend'
EMAIL_HOST ='smtp.qq.com'
EMAIL_PORT = 25
EMAIL_HOST_USER = '2433066075@qq.com'
EMAIL_HOST_PASSWORD = 'cjmmkyntpkvcdjfa' #This is not your gmail password.
DEFAULT_FROM_EMAIL = '2433066075@qq.com'
EMAIL_USE_TLS = True
TOOLS_ENABLED = True
TOOLS_PATH = os.path.join(BASE_DIR, 'tools')
TOOL_UPLOAD_NOTICE = ''

# Use ldap login
#
# import ldap
# from django_auth_ldap.config import LDAPSearch
#
# AUTHENTICATION_BACKENDS = (
#     'django_auth_ldap.backend.LDAPBackend',
#     'django.contrib.auth.backends.ModelBackend',
# )
#
# AUTH_LDAP_SERVER_URI = "ldap_host"
# AUTH_LDAP_BIND_DN = "ldap_bind_dn"
# AUTH_LDAP_BIND_PASSWORD = "ldap_bind_pw"
# AUTH_LDAP_USER_SEARCH = LDAPSearch("ou=People,dc=mafiasi,dc=de",
#     ldap.SCOPE_SUBTREE, "(uid=%(user)s)")
# AUTH_LDAP_ALWAYS_UPDATE_USER = True
#
# from django_auth_ldap.config import LDAPSearch, PosixGroupType
#
# AUTH_LDAP_GROUP_SEARCH = LDAPSearch("ou=groups,dc=mafiasi,dc=de",
#     ldap.SCOPE_SUBTREE, "(objectClass=posixGroup)"
# )
# AUTH_LDAP_GROUP_TYPE = PosixGroupType()
# AUTH_LDAP_FIND_GROUP_PERMS = True
# AUTH_LDAP_MIRROR_GROUPS = True
#
# AUTH_LDAP_USER_ATTR_MAP = {"first_name": "givenName", "last_name": "sn", "email": "mail"}
#
# AUTH_LDAP_USER_FLAGS_BY_GROUP = {
#     "is_staff": ["cn=Editoren,ou=groups,dc=mafiasi,dc=de",
#                  "cn=Server-AG,ou=groups,dc=mafiasi,dc=de"],
#     "is_superuser": "cn=Server-AG,ou=groups,dc=mafiasi,dc=de"
# }


# Usage of sentry for errorreporting (remember to activate raven in installed apps)
# import raven

# RAVEN_CONFIG = {
#     'dsn': 'threaded+requests+https://Sentry-DSN',
#     # If you are using git, you can also automatically configure the
#     # release based on the git info.
#     #'release': raven.fetch_git_sha(os.path.dirname(__file__)),
#     'release': open('/opt/imagetagger/.releaseversion').read(),
# }
