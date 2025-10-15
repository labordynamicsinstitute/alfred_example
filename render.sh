#!/bin/bash

# Render main.Rmd to HTML using R 4.4.3 tidyverse container

docker run --rm \
  -v "$(pwd):/work" \
  -w /work \
  rocker/tidyverse:4.4.3 \
  run.sh
