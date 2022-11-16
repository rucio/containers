# Rucio - Scientific Data Management

Rucio is a software framework that provides functionality to organize, manage, and access large volumes of scientific data using customisable policies. The data can be spread across globally distributed locations and across heterogeneous data centers, uniting different storage and network technologies as a single federated entity. Rucio offers advanced features such as distributed data recovery or adaptive replication, and is highly scalable, modular, and extensible. Rucio has been originally developed to meet the requirements of the high-energy physics experiment ATLAS, and is continuously extended to support LHC experiments and other diverse scientific communities.

## React WebUI Container

This repository contains the Docker container and configuration file templates for the new [React Based WebUI](https://github.com/rucio/webui). For the older WebUI, please go [here](https://github.com/rucio/containers/tree/master/ui).

## Documentation

Instructions to use and deploy the docker image for the new Rucio WebUI can be found [here](https://rucio.cern.ch/documentation/installing_webui). General information and latest documentation about Rucio can be found [here](https://rucio.cern.ch/documentation/). 

## Deployment

This section decribes deploying the Rucio WebUI via Docker. For Kubernetes deployment, please refer to the [helm-charts](https://github.com/rucio/helm-charts/tree/master/charts/rucio-ui) instead.

This image provides the Rucio WebUI which works as a web frontend to the Rucio server. The WebUI container can be built with the following command, where `TAG` is the version of the webui to be used (should already be available on [rucio/webui](https://github.com/rucio/webui) repository) and the build context is the directory containing the Dockerfile:

```
docker build --rm --build-arg TAG=1.29.0-pre-alpha --target=production --tag=webui .
```

Pre-built images are available on [Docker Hub](https://hub.docker.com/u/rucio/).

A WebUI instance with the minimal configuration can be started like this:

```
docker run \
    --name rucio-webui \
    -p 80:80 -p 443:443 \
    -e RUCIO_ENABLE_SSL=False \
    -e RUCIO_HOST=<rucio_server_url> \
    rucio/rucio-webui:latest
```
The `<rucio_server_url>` must point to the instance of rucio-server that the WebUI will connect to. The WebUI will be available at `http://<host>:80`. Please note that without SSL, the WebUI will not be able to perform `x509` authentication workflow.

To start the WebUI container with TLS Termination and x509 authentication, you must provide host certificate, key and the the CA certificate as volumes.

```
docker run \
    --name webui \
    -p 80:80 -p 443:443 \
    -e RUCIO_ENABLE_SSL=True \
    -e RUCIO_HOST=https://rucio-devmaany.cern.ch \
    -v <path_to>/hostcert.pem:/etc/grid-security/hostcert.pem \
    -v <path_to>/hostkey.pem:/etc/grid-security/hostkey.pem \
    -v <path_to>/ca-bundle.pem:/etc/grid-security/ca.pem \
    rucio/rucio-webui
```

## Configuration
The WebUI container can be configured using environment variables. There are two categories of the environment variables:
1. React App Configuration
2. Web Server (Apache) Configuration

Except for `RUCIO_HOST`, the React App Configuration variables are prefixed with `WEBUI_` and are used to process the `.env.default.j2` template, which creates the environment file used by the React App. Additional configuration variables can be passed to the React app. These configration variables must be prefixed with `RUCIO_CFG_REACT_APP_` and can be passed to the container with the `-e RUCIO_CFG_REACT_ENV_<var>=value` flag. 

The Web Server Configuration variables are prefixed with `RUCIO_`. 

The following table lists the available configuration variables:

### React App Configuration
The following environment variables are used to configure the React App.

| Variable | Description | Required/Optional |
| --- | --- | --- |
| `RUCIO_HOST` | The URL of the Rucio server to connect to. | Required |
| `WEBUI_LOGIN_PAGE_IMAGE_PRIMARY` | The path to the primary image to be displayed on the login page. | Optional, the image must be volume mounted onto the container |
| `WEBUI_LOGIN_PAGE_IMAGE_SECONDARY` | The path to the secondary image to be displayed on the login page. | Optional, the image must be volume mounted onto the container |

## OIDC Authentication

The WebUI supports multiple OIDC Providers. For security reasons, it is highly recommended that the OIDC providers support the PKCE workflow, otherwise any `client_secret` variables would be exposed to the browsers running the WebUI. 

For each OIDC provider, you must register the WebUI as a `client` and generate a `client_id`.  You can use the `{https/http}://{rucio_web_ui_domain}/` as the `redirect_uri`. 

Then, you can specify the OIDC client configuration in the WebUI by providing the following environment variables ( increment the number for each provider ):

| Variable | Description | Required/Optional |
| --- | --- | --- |
| `RUCIO_CFG_OIDC_REACT_APP_oidc_provider_<num>` | The name of the OIDC provider. | Required |
| `RUCIO_CFG_OIDC_REACT_APP_oidc_client_id_<num>` | The client ID of the OIDC provider. | Required |
| `RUCIO_CFG_OIDC_REACT_APP_oidc_authorization_endpoint_<num>` | The authorization endpoint of the OIDC provider, without the trailing '/'. | Required |
| `RUCIO_CFG_OIDC_REACT_APP_oidc_token_endpoint_<num>` | The token endpoint of the OIDC provider, without the trailing '/'. | Required |
| `RUCIO_CFG_OIDC_REACT_APP_oidc_redirect_uri_<num>` | The redirect URI of the OIDC provider. | Required |

## Web Server Configuration

The following environment variables are used to configure the rucio specific aspects of the Apache Web Server.

| Variable | Description | Defaults |
| --- | --- | --- |
| `RUCIO_HOSTNAME` | This variable sets the server name in the apache config. |  |
| `RUCIO_SERVER_ADMIN` | This variable sets the server admin in the apache config. |  |
| `RUCIO_ENABLE_SSL` | Enable SSL/TLS Termination. | Optional, default: `False` |
| `RUCIO_CA_PATH` | If you are using SSL and want use `SSLCACertificatePath` and `SSLCARevocationPath` you can do so by specifying the path in this variable. | Optional, Default: `/etc/grid-security/ca.pem` |
| `RUCIO_LOG_FORMAT` | The default rucio log format is `%h\t%t\t%{X-Rucio-Forwarded-For}i\t%T\t%D\t\"%{X-Rucio-Auth-Token}i\"\t%{X-Rucio-RequestId}i\t%{X-Rucio-Client-Ref}i\t\"%r\"\t%>s\t%b` You can set your own format using this variable. |  |
| `RUCIO_ENABLE_LOGS`| By default the log output of the web server is written to stdout and stderr. If you set this variable to `True` the output will be written to `access_log` and `error_log` under `/var/log/httpd`. |  |
| `RUCIO_LOG_LEVEL` | The log level of Apache | Default: info |
| `RUCIO_HTTPD_LOG_DIR` | If `RUCIO_ENABLE_LOGS` is set use this variable to change the default logfile output directory.  |  |
| `RUCIO_CA_REVOCATION_CHECK` | Sets the `SSLCARevocationCheck` variable for Apache  | Default: `chain`  |

The following environment variables are used to configure the Apache Web Server. Please take a look at `httpd.conf.j2` for more information.

| Variable | Description | Defaults |
| --- | --- | --- |
| `RUCIO_HTTPD_SERVER_LIMIT` |  |  |
| `RUCIO_HTTPD_MAX_REQUESTS_PER_CHILD` |  |  |
| `RUCIO_HTTPD_KEEP_ALIVE_TIMEOUT` |  |  |
| `RUCIO_HTTPD_MAX_SPARE_THREADS` |  |  |
| `RUCIO_HTTPD_TIMEOUT` |  |  |
| `RUCIO_HTTPD_MPM_MODE` | This variable sets the MPM mode. | The default is "event".  |
| `RUCIO_HTTPD_START_SERVERS` |  |  |
| `RUCIO_HTTPD_MAX_CONNECTIONS_PER_CHILD` |  |  |
| `RUCIO_HTTPD_KEEP_ALIVE` |  |  |
| `RUCIO_HTTPD_MIN_SPARE_THREADS` |  |  |
| `RUCIO_HTTPD_MAX_CLIENTS` |  |  |
| `RUCIO_HTTPD_MAX_KEEP_ALIVE_REQUESTS` |  |  |
| `RUCIO_HTTPD_MIN_SPARE_SERVERS` |  |  |
| `RUCIO_HTTPD_THREADS_LIMIT` |  |  |
| `RUCIO_HTTPD_MAX_SPARE_SERVERS` |  |  |
| `RUCIO_HTTPD_MAX_REQUEST_WORKERS` |  |  |
| `RUCIO_HTTPD_THREADS_PER_CHILD` |  |  |

## Developers

For information on how to contribute to Rucio, please refer and follow our [CONTRIBUTING](<https://github.com/rucio/rucio/blob/master/CONTRIBUTING.rst>) guidelines.

The new WebUI is a single-page React app, therefore, `httpd` is only used for providing `TLS Termination` and `SSL Client Certificate Verification` capabilities.

The configuration parameters for the react app itself are included in the `.env.default.j2` template. In the webui repository, these environment variables are present in the [.env.template](https://github.com/rucio/webui/blob/master/.env.template) file. Please make sure that all the required environment variables required by the react application can be configured via the `.env.default.j2` template.

The React app gets built into a static website after running `npm build` in the `docker-entrypoint.sh`. The build process also embeds all environment variables in the final processed output of `.env.default.j2` file (i.e. /opt/rucio/webui/.env inside the container) in the source of the static web application. When httpd serves the webui, it returns the source of the static web application. Therefore, it is highly recommended to **NOT specify any secrets via the environment variables used in .env.default.j2 configuration template**.

The Dockerfile fetches the source code from a **tagged release of the webui repository ( no node package is pushed to npm)**. The tagged release is specified by the `--build-arg TAG=<value>` argument of the `docker build` command.

The file `rucio.conf.j2` specifies webui specific configuration for `httpd`. The status of the `x509` certificate veritication is embedded into the `X-SSL-Client-S-DN` and `X-SSL-Client-Verify` response headers. These headers are used by the webui to figure out if x509 was used as an authentication method and whether a valid client certificate was presented.

For x509 Client Certificate Vertification, the initial idea was to define a new Location in httpd config under the virtual host listening at port 443
```
<Location /auth/x509> 
 SSLVerifyClient optional_no_ca
 SSLVerifyDepth 10
</Location>
```
This would allow the end-users to click on the `x509 Authentication` button in the webui login page, which would then initiate the client certificate request and vertification process.

While, this is a totally valid httpd configuration, most browsers, at the time of writing this document, do not support [`post-handshake`](https://stackoverflow.com/questions/53062504/apache-2-4-37-with-openssl-1-1-1-cannot-perform-post-handshake-authentication) authentication. Therefore, the `SSLVerifyClient` directive must be used in the <VirtualHost *:443> directive.

In case this changes in future, please coordinate with the developers of the webui to adapt to the `post-handshake` authentication scenario.

## Enabling docker auto builds
Once the new webui is ready to be included as part of the main release process of Rucio, it must be added to the docker auto build and push workflow defined in this repository.

To do so, please add
```
'webui, prepend-rucio, prepend-release, push-tagged, push-latest'
```
to the [build context](
https://github.com/rucio/containers/blob/df0d2a40a24db32523ed218b7e340616832f459a/.github/workflows/docker-auto-build.yml#L13-L28).
