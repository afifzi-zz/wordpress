#!/bin/bash

terraform apply -var="replicaCount=$1" --auto-approve