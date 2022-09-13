# Rucio - Scientific Data Management

Rucio is a software framework that provides functionality to organize, manage, and access large volumes of scientific data using customisable policies. The data can be spread across globally distributed locations and across heterogeneous data centers, uniting different storage and network technologies as a single federated entity. Rucio offers advanced features such as distributed data recovery or adaptive replication, and is highly scalable, modular, and extensible. Rucio has been originally developed to meet the requirements of the high-energy physics experiment ATLAS, and is continuously extended to support LHC experiments and other diverse scientific communities.

## React WebUI Container

This repository contains the Docker container and configuration file templates for the new [React Based WebUI](https://github.com/rucio/webui). For the older WebUI, please go [here](https://github.com/rucio/containers/tree/master/ui).

## Documentation

Instructions to use and deploy the docker image for the new Rucio WebUI can be found [here](https://rucio.cern.ch/documentation/installing_webui). General information and latest documentation about Rucio can be found [here](https://rucio.cern.ch/documentation/). 

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
