#!/bin/bash

while :
do
    rucio-conveyor-submitter --run-once
    rucio-conveyor-poller --run-once --older-than 0
    rucio-conveyor-finisher --run-once
    rucio-hermes --run-once
done
