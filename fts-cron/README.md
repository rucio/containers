# Rucio - Scientific Data Management

Rucio is a software framework that provides functionality to organize, manage, and access large volumes of scientific data using customisable policies. The data can be spread across globally distributed locations and across heterogeneous data centers, uniting different storage and network technologies as a single federated entity. Rucio offers advanced features such as distributed data recovery or adaptive replication, and is highly scalable, modular, and extensible. Rucio has been originally developed to meet the requirements of the high-energy physics experiment ATLAS, and is continuously extended to support LHC experiments and other diverse scientific communities.

## Documentation

General information and latest documentation about Rucio can be found at [readthedocs](https://rucio.readthedocs.io) or on our [webpage](https://rucio.cern.ch).

## Developers

For information on how to contribute to Rucio, please refer and follow our [CONTRIBUTING](<https://github.com/rucio/rucio/blob/master/CONTRIBUTING.rst>) guidelines.

# FTS Cronjob Container

The FTS Cronjob is installed by the helm chart and runs once upon installation to create the required `x509up` certificate for RUCIO to connect to an FTS instance.

-- insert description for different vo's and value options --

