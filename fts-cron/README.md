# Rucio - Scientific Data Management

Rucio is a software framework that provides functionality to organize, manage, and access large volumes of scientific data using customisable policies. The data can be spread across globally distributed locations and across heterogeneous data centers, uniting different storage and network technologies as a single federated entity. Rucio offers advanced features such as distributed data recovery or adaptive replication, and is highly scalable, modular, and extensible. Rucio has been originally developed to meet the requirements of the high-energy physics experiment ATLAS, and is continuously extended to support LHC experiments and other diverse scientific communities.

## Documentation

General information and latest documentation about Rucio can be found at [readthedocs](https://rucio.readthedocs.io) or on our [webpage](https://rucio.cern.ch).

## Developers

For information on how to contribute to Rucio, please refer and follow our [CONTRIBUTING](<https://github.com/rucio/rucio/blob/master/CONTRIBUTING.rst>) guidelines.

# FTS Cronjob Container

The [FTS renew proxy cronjob](https://github.com/rucio/helm-charts/blob/master/charts/rucio-daemons/templates/renew-fts-cronjob.yaml) is installed by the helm chart and runs once upon installation to create the required `<releasename>-rucio-x509up` certificate for RUCIO to connect to an FTS instance.

If the `vo` requires a special setup and thus is listed in the `docker-entrypoint.sh` script, it can be specified there. Any other value will lead to the execution of the default script `renew_fts_proxy.sh.j2`, which requires a `cert` and `key` secret (`<releasename>-fts-key` and `<releasename>-fts-cert`).  
**`cert` and `key` filename in the secrets need to correspond to `usercert.pem` and `userkey.pem`!**

If required a grid passphrase can be passed for `voms-proxy-init` by enabling `gridPassphraseRequired` with `true` in the helm chart values, and creating the required certificate `<releasename>-grid-passphrase`. An example command would be: `kubectl create secret generic <releasename>-grid-passphrase --from-literal=passphrase='<grid-passphrase>' -n <namespace>`.  
**The key:value pair in the grid secret needs to be `passphrase=<grid-passphrase>`!**
