#!/bin/bash

TEMPLATE=$1
OPTS=$2

coder templates push -d ./workspace/$TEMPLATE $TEMPLATE $OPTS