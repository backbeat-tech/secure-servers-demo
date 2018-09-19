from __future__ import absolute_import

import logging
import salt.utils

log = logging.getLogger(__name__)

def database_backend_enabled(name):
    """
     Equivalent to 'vault secrets enable database'
    """
    ret = {
        'name': name,
        'changes': {},
        'result': True,
        'comment': '',
    }

    try:
        url = "v1/sys/mounts/{}/tune".format(name)
        response = __utils__['vault.make_request']('GET', url)
        if response.status_code == 200:
            ret['comment'] = "Database backend is already enabled"
            return ret

        url = "v1/sys/mounts/{}".format(name)
        data = {
            "type": "database",
            "description": "Database backend for secure servers"
        }
        response = __utils__['vault.make_request']('POST', url, json=data)
        if response.status_code != 200:
            response.raise_for_status()

        ret['comment'] = "Enabled backend of type 'database' at /{}".format(name)
        ret['changes'] = {
            name: "enabled"
        }
        return ret
    except Exception as err:
        ret['result'] = False
        msg = '{}: {}'.format(type(err).__name__, err)
        log.error(msg)
        ret['comment'] = msg

        return ret

def postgres_database_enabled(name, connection_url='', username='', password='', allowed_roles='', mount_point='database'):
    """
     Equivalent to 'vault write database/config/<name>'
    """
    ret = {
        'name': name,
        'changes': {},
        'result': True,
        'comment': '',
    }

    data = {
        "plugin_name": "postgresql-database-plugin",
        "allowed_roles": allowed_roles,
        "connection_url": connection_url,
        "username": username,
        "password": password,
    }

    try:
        path = "/{}/config/{}".format(mount_point, name)
        url = "v1"+path
        response = __utils__['vault.make_request']('GET', url)
        if response.status_code == 200:
            ret['comment'] = "Database is already enabled at {}".format(path)
            return ret

        response = __utils__['vault.make_request']('POST', url, json=data)
        if response.status_code != 200:
            response.raise_for_status()

        ret['comment'] = "Enabled database at {}".format(path)
        ret['changes'] = {
            name: "enabled"
        }

        return ret
    except Exception as err:
        ret['result'] = False
        msg = '{}: {}'.format(type(err).__name__, err)
        log.error(msg)
        ret['comment'] = msg

        return ret



def postgres_role_enabled(name, db_name='', creation_statements=None, mount_point='database', default_ttl=None, max_ttl=None):
    """
     Equivalent to 'vault write database/roles/<name>'
    """
    ret = {
        'name': name,
        'changes': {},
        'result': True,
        'comment': '',
    }

    try:
        path = "/{}/roles/{}".format(mount_point, name)
        url = "v1"+path
        response = __utils__['vault.make_request']('GET', url)
        if response.status_code == 200:
            ret['comment'] = "Role is already enabled at {}".format(path)
            return ret


        data = {
            "db_name": db_name,
            "creation_statements": "CREATE ROLE \"{{name}}\" WITH LOGIN PASSWORD '{{password}}' VALID UNTIL '{{expiration}}'; GRANT SELECT ON ALL TABLES IN SCHEMA public TO \"{{name}}\";",
            "default_ttl": default_ttl,
            "max_ttl": max_ttl,
        }
        response = __utils__['vault.make_request']('POST', url, json=data)
        if response.status_code != 200:
            response.raise_for_status()

        ret['comment'] = "Enabled role at {}".format(path)
        ret['changes'] = {
            name: "enabled"
        }

        return ret
    except Exception as err:
        ret['result'] = False
        msg = '{}: {}'.format(type(err).__name__, err)
        log.error(msg)
        ret['comment'] = msg

        return ret
