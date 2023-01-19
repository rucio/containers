# Rucio - Scientific Data Management

Rucio is a software framework that provides functionality to organize, manage, and access large volumes of scientific data using customisable policies. The data can be spread across globally distributed locations and across heterogeneous data centers, uniting different storage and network technologies as a single federated entity. Rucio offers advanced features such as distributed data recovery or adaptive replication, and is highly scalable, modular, and extensible. Rucio has been originally developed to meet the requirements of the high-energy physics experiment ATLAS, and is continuously extended to support LHC experiments and other diverse scientific communities.

## Documentation

General information and latest documentation about Rucio can be found at [readthedocs](https://rucio.readthedocs.io) or on our [webpage](https://rucio.cern.ch).

## Developers

For information on how to contribute to Rucio, please refer and follow our [CONTRIBUTING](<https://github.com/rucio/rucio/blob/master/CONTRIBUTING.rst>) guidelines.

# FTS Cronjob Container

The FTS Cronjob is installed by the helm chart and runs once upon installation to create the required `<releasename>-rucio-x509up` certificate for RUCIO to connect to an FTS instance.

The cronjob can be enabled by setting `enabled` to `1`:

```yaml
ftsRenewal:
  enabled: 1
  schedule: "12 */6 * * *"
  image:
    repository: rucio/fts-cron
    tag: latest
    pullPolicy: Always
  vo: "<your-vo>"
  voms: "<your-voms>"
  gridPassphraseRequired: false
  servers: "https://fts3-devel.cern.ch:8446,https://cmsfts3.fnal.gov:8446,https://fts3.cern.ch:8446,https://lcgfts3.gridpp.rl.ac.uk:8446,https://fts3-pilot.cern.ch:8446"
```

If your `vo` requires a special setup and thus is listed in the `docker-entrypoint.sh` script, you can specify it there. Any other value will lead to the execution of the default script `renew_fts_proxy.sh.j2`, which requires a `cert` and `key` secret (`<releasename>-fts-key` and `<releasename>-fts-cert`).  
**Please make sure, your `cert` and `key` filename in the secrets correspond to `usercert.pem` and `userkey.pem`!**

If required you can pass a grid passphrase for `voms-proxy-init` by enabling `gridPassphraseRequired` with `true` and creating the required certificate `<releasename>-grid-passphrase`. An example command would be: `kubectl create secret generic <releasename>-grid-passphrase --from-literal=passphrase='<grid-passphrase>' -n <namespace>`.  
**Please make sure, you use the correct key:value pair in the secret, as shown in the example command!**
