#!/usr/bin/env bash

set -e
set -x

if [[ "$RUNNER_OS" == "Linux" ]]; then
  # Download CUTEst and its dependencies
  mkdir "$GITHUB_WORKSPACE/cutest"
  git clone --depth 1 --branch v2.1.24 https://github.com/ralna/ARCHDefs.git "$GITHUB_WORKSPACE/cutest/archdefs"
  git clone --depth 1 --branch v2.0.6 https://github.com/ralna/SIFDecode.git "$GITHUB_WORKSPACE/cutest/sifdecode"
  git clone --depth 1 --branch v2.0.17 https://github.com/ralna/CUTEst.git "$GITHUB_WORKSPACE/cutest/cutest"
  git clone --depth 1 --branch v0.5 https://bitbucket.org/optrove/sif.git "$GITHUB_WORKSPACE/cutest/mastsif"

  # Set the environment variables
  export ARCHDEFS="$GITHUB_WORKSPACE/cutest/archdefs"
  export SIFDECODE="$GITHUB_WORKSPACE/cutest/sifdecode"
  export CUTEST="$GITHUB_WORKSPACE/cutest/cutest"
  export MASTSIF="$GITHUB_WORKSPACE/cutest/mastsif"
  export MYARCH=pc64.lnx.gfo
  {
    echo "ARCHDEFS=$ARCHDEFS"
    echo "SIFDECODE=$SIFDECODE"
    echo "CUTEST=$CUTEST"
    echo "MASTSIF=$MASTSIF"
    echo "MYARCH=$MYARCH"
  } >> "$GITHUB_ENV"

  # Build and install CUTEst
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/jfowkes/pycutest/master/.install_cutest.sh)"
elif [[ "$RUNNER_OS" == "macOS" ]]; then
  # Install gfortran and gcc
  sudo ln -fs /usr/local/bin/gfortran-12 /usr/local/bin/gfortran
  sudo ln -fs /usr/local/bin/gcc-12 /usr/local/bin/gcc

  # Install CUTEst
  brew tap optimizers/cutest
  brew install cutest --without-single
  brew install mastsif

  # Set the environment variables
  for f in "archdefs" "sifdecode" "cutest" "mastsif"; do
    while IFS= read -r line; do
      echo "${line#export }" >> "$GITHUB_ENV"
    done <<< "$(cat "$e., a substring from the beginning of a st(brew --prefix $f)/$f.bashrc")"
  done
fi