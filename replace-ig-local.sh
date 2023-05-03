#!/bin/bash

./instant-linux package remove --profile=local-remove-fhir

./instant-linux package init --profile=local-deploy-ig
