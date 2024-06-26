# Rucio - Scientific Data Management

## (WebUI Container)

Rucio is a software framework that provides functionality to organize, manage, and access large volumes of scientific data using customisable policies. The data can be spread across globally distributed locations and across heterogeneous data centers, uniting different storage and network technologies as a single federated entity. Rucio offers advanced features such as distributed data recovery or adaptive replication, and is highly scalable, modular, and extensible. Rucio has been originally developed to meet the requirements of the high-energy physics experiment ATLAS, and is continuously extended to support LHC experiments and other diverse scientific communities.

## Documentation

General information and latest documentation about Rucio can be found at [readthedocs](https://rucio.readthedocs.io) or on our [webpage](https://rucio.cern.ch).

## Developers

For information on how to contribute to Rucio, please refer and follow our [CONTRIBUTING](<https://github.com/rucio/rucio/blob/master/CONTRIBUTING.rst>) guidelines.

## Getting Started

This image provides the Rucio WebUI which works as a web frontend to the Rucio server. It supports MySQL, PostgreSQL, Oracle and SQLite as database backends.

A WebUI instance with the minimal configuration can be started like this:

    docker run \
      --name=rucio-webui \
      -v /tmp/ca.pem:/etc/grid-security/ca.pem \
      -v /tmp/hostcert.pem:/etc/grid-security/hostcert.pem \
      -v /tmp/hostkey.pem:/etc/grid-security/hostkey.pem \
      -v /tmp/rucio.cfg:/opt/rucio/etc/rucio.cfg \
      -p 443:443 \
      -e RUCIO_PROXY="server.rucio" \
      -e RUCIO_AUTH_PROXY="auth.rucio" \
      rucio/rucio-ui

The rucio.cfg is used to configure the database backend, which is only needed for authentication and should point to the same database as the Rucio authentication server.

SSL is necessary for the WebUI so you need to include the host certificate, key and the the CA certificate as volumes.

`RUCIO_PROXY` and `RUCIO_AUTH` should point to your rucio server and rucio authentication endpoints. They are necessary for the WebUI to work.

## Environment Variables

As shown in the examples above the rucio-server image can be configured using environment variables that are passed with `docker run`. Below is a list of all available variables and their behaviour:

### `RUCIO_PROXY`

Set this value to the address where you Rucio server can be reached. The WebUI uses a local httpd proxy to communicated with the Rucio server. This is necessary to circumvent possible cross-origin request problems.

### `RUCIO_PROXY_SCHEME`

This variable can be used the change the proxy url scheme. The default is "https".

### `RUCIO_AUTH_PROXY`

Same as `RUCIO_PROXY` but for the authentication server (which can be add different host as the main server).

### `RUCIO_AUTH_PROXY_SCHEME`

Same as `RUCIO_PROXY_SCHEME` but for the authentication server.

### `RUCIO_CA_PATH`

If you are using SSL and want use `SSLCACertificatePath` and `SSLCARevocationPath` you can do so by specifying the path in this variable.

### `RUCIO_CA_FILE`
If you are using SSL and do not want to hash the CA certificates you can specify the path to the single CA file that contains all of the required certificates in this variable. It sets the `SSLCACertificateFile`  and `SSLCARevocationFile` directives in the apache config.

### `RUCIO_ENABLE_LOGS`

By default the log output of the web server is written to stdout and stderr. If you set this variable to `True` the output will be written to `access_log` and `error_log` under `/var/log/httpd`.

### `RUCIO_HTTPD_LOG_DIR`

If `RUCIO_ENABLE_LOGS` is set use this variable to change the default logfile output directory.

### `RUCIO_LOG_LEVEL`

The default log level is `info`. You can change it using this variable.

### `RUCIO_LOG_FORMAT`

The default rucio log format is `%h\t%t\t%{X-Rucio-Forwarded-For}i\t%T\t%D\t\"%{X-Rucio-Auth-Token}i\"\t%{X-Rucio-RequestId}i\t%{X-Rucio-Client-Ref}i\t\"%r\"\t%>s\t%b`
You can set your own format using this variable.

### `RUCIO_HOSTNAME`

This variable sets the server name in the apache config.

### `RUCIO_SERVER_ADMIN`

This variable sets the server admin in the apache config.

### `RUCIO_HTTPD_MPM_MODE`

This variable sets the MPM mode. The default is "event".

### `RUCIO_HTTPD_ADDITIONAL_PROXY_CONF`

This variable can be used to add an additional `ProxyPass` and corresponding `ProxyPassReverse` directive to the apache config. This can be useful if you want to add additional proxies to the WebUI. The value should be a string with the format `/{path} {url}`. For example `RUCIO_HTTPD_ADDITIONAL_PROXY_CONF="/foo http://bar"` will add the following lines to the apache config located at `/etc/httpd/conf.d/rucio.conf` inside the container:

```bash
    ProxyPass /foo http://bar
    ProxyPassReverse /foo http://bar
```

You can also specify multiple proxies if you specify the value of the environment variable in the following format: `/{path1} {url1}, /{path2} {url2}, ...`. For example `RUCIO_HTTPD_ADDITIONAL_PROXY_CONF="/foo http://bar, /baz http://qux"` will add the following lines to the apache config located at `/etc/httpd/conf.d/rucio.conf` inside the container:

```bash
    ProxyPass /foo http://bar
    ProxyPassReverse /foo http://bar
    ProxyPass /baz http://qux
    ProxyPassReverse /baz http://qux
```

### `RUCIO_HTTPD_ADDITIONAL_REDIRECTS`

This variable can be used to add an additional `Redirect` in the apache config. The value should be a string with the format `/{path} {url}`. For example `RUCIO_HTTPD_ADDITIONAL_REDIRECTS="/foo http://bar"` will add the following lines to the apache config located at `/etc/httpd/conf.d/rucio.conf` inside the container:

```bash
    Redirect /foo http://bar
```

You can add multiple redirects if you specify the value of the environment variable in the following format: `/{path1} {url1}, /{path2} {url2}, ...`. For example `RUCIO_HTTPD_ADDITIONAL_REDIRECTS="/foo http://bar, /baz http://qux"` will add the following lines to the apache config located at `/etc/httpd/conf.d/rucio.conf` inside the container:

```bash
    Redirect /foo http://bar
    Redirect /baz http://qux
```

### `RUCIO_HTTPD_PROXY_PROTOCOL_ENABLED`

This variable can be used to enable the `ProxyProtocol` module in the apache config. The default is `Off`. It sets the `RemoteIPProxyProtocol` directive in the apache config.

### `RUCIO_HTTPD_PROXY_PROTOCOL_EXCEPTIONS`

This variable can be used to set the `RemoteIPProxyProtocolExceptions` directive in the apache config. If the `RUCIO_HTTPD_PROXY_PROTOCOL_ENABLED` is set to `True`, then the supplied values are excluded from proxy protocol processing.

## `RUCIO_CFG` configuration parameters:

Environment variables can be used to set values for the auto-generated rucio.cfg. The names are derived from the actual names in the configuration file prefixed by `RUCIO_CFG`, e.g., the `default` value in the `database` section becomes `RUCIO_CFG_DATABASE_DEFAULT`.
The available environment variables are:

* `RUCIO_CFG_COMMON_LOGDIR`
* `RUCIO_CFG_COMMON_LOGLEVEL`
* `RUCIO_CFG_COMMON_MAILTEMPLATEDIR`
* `RUCIO_CFG_COMMON_MULTI_VO`
* `RUCIO_CFG_DATABASE_DEFAULT`
* `RUCIO_CFG_DATABASE_ECHO`
* `RUCIO_CFG_DATABASE_MAX_OVERFLOW`
* `RUCIO_CFG_DATABASE_POOL_RECYCLE`
* `RUCIO_CFG_DATABASE_POOL_RESET_ON_RETURN`
* `RUCIO_CFG_DATABASE_POOL_SIZE`
* `RUCIO_CFG_DATABASE_POOL_TIMEOUT`
* `RUCIO_CFG_DATABASE_POWUSERACCOUNT`
* `RUCIO_CFG_DATABASE_POWUSERPASSWORD`
* `RUCIO_CFG_DATABASE_SCHEMA`
* `RUCIO_CFG_MONITOR_CARBON_PORT`
* `RUCIO_CFG_MONITOR_CARBON_SERVER`
* `RUCIO_CFG_MONITOR_USER_SCOPE`
* `RUCIO_CFG_NONGRID_TRACE_BROKERS`
* `RUCIO_CFG_NONGRID_TRACE_PASSWORD`
* `RUCIO_CFG_NONGRID_TRACE_PORT`
* `RUCIO_CFG_NONGRID_TRACE_TOPIC`
* `RUCIO_CFG_NONGRID_TRACE_TRACEDIR`
* `RUCIO_CFG_NONGRID_TRACE_USERNAME`
* `RUCIO_CFG_OIDC_ADMIN_ISSUER`
* `RUCIO_CFG_OIDC_IDPSECRETS`
* `RUCIO_CFG_POLICY_LFN2PFN_ALGORITHM_DEFAULT`
* `RUCIO_CFG_POLICY_LFN2PFN_MODULE`
* `RUCIO_CFG_POLICY_PACKAGE`
* `RUCIO_CFG_POLICY_PERMISSION`
* `RUCIO_CFG_POLICY_SCHEMA`
* `RUCIO_CFG_POLICY_SUPPORT`
* `RUCIO_CFG_POLICY_SUPPORT_RUCIO`
* `RUCIO_CFG_TRACE_BROKERS`
* `RUCIO_CFG_TRACE_PASSWORD`
* `RUCIO_CFG_TRACE_PORT`
* `RUCIO_CFG_TRACE_TOPIC`
* `RUCIO_CFG_TRACE_TRACEDIR`
* `RUCIO_CFG_TRACE_USERNAME`
* `RUCIO_CFG_WEBUI_USERCERT`

## Getting Support

If you are looking for support, please contact our mailing list rucio-users@googlegroups.com
or join us on our [slack support](<https://rucio.slack.com/messages/#support>) channel.
