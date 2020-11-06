#!/bin/bash

set -e

#mvn clean verify package
mvn clean package -e -Dmaven.test.skip=true
