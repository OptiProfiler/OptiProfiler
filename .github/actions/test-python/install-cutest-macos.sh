#!/usr/bin/env bash

set -e
set -x

sudo ln -fs /usr/local/bin/gfortran-12 /usr/local/bin/gfortran
brew tap optimizers/cutest
brew install cutest --without-single
brew install mastsif
for f in "archdefs" "mastsif" "sifdecode" "cutest"; do
  EXPORTED_PATH=$(cat "$(brew --prefix $f)/$f.bashrc")
  echo "${EXPORTED_PATH#export}" >> "$GITHUB_ENV"
done
