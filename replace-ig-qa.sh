#!/bin/bash

./instant-linux package remove --profile=qa-remove-fhir

./instant-linux package init --profile=qa-deploy-ig
