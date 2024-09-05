#!/bin/bash

DIR_PATH=$1
VAR_FILE_PATH=../$2

terraform -chdir=$DIR_PATH destroy -auto-approve -var-file=$VAR_FILE_PATH