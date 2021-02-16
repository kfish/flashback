#!/bin/sh

INPUT=$1
OUTPUT=$2

cat $1 | sed > $2 \
  -e "s#https://code.getmdl.io/1.3.0#assets#" \
  -e "s#https://fonts.googleapis.com/icon?family=Material+Icons#assets/material-icons.css#" \
  -e "s#https://fonts.googleapis.com/css?family=Roboto:400,300,500|Roboto+Mono|Roboto+Condensed:400,700&subset=latin,latin-ext#assets/roboto-400-300-500.css#"
