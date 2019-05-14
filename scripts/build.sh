#!/usr/bin/env bash

set -o pipefail
set -o nounset
set -o errexit

err_report() {
    echo "Exited with error on line $1"
}
trap 'err_report $LINENO' ERR

LOCATION=`pwd`

clean () {
  cd $LOCATION/clients/cli
  cargo clean
  cd $LOCATION
  rm -rf $LOCATION/otoroshi/target/universal
  rm -rf $LOCATION/manual/target/universal
  rm -rf $LOCATION/docs/manual
}

build_cli () {
  cd $LOCATION/clients/cli
  cargo build --release
}

build_ui () {
  cd $LOCATION/otoroshi/javascript
  yarn install
  yarn build
}

build_manual () {
  cd $LOCATION/manual
  sbt ';clean;paradox'
  cp -r $LOCATION/manual/target/paradox/site/main $LOCATION/docs
  mv $LOCATION/docs/main $LOCATION/docs/manual
}

build_server () {
  cd $LOCATION/otoroshi
  sbt ';clean;compile;dist;assembly'
}

test_server () {
  cd $LOCATION/otoroshi
  TEST_STORE=inmemory sbt test
  rc=$?; if [ $rc != 0 ]; then exit $rc; fi
  # TEST_STORE=leveldb sbt test
  # rc=$?; if [ $rc != 0 ]; then exit $rc; fi
  # TEST_STORE=redis sbt test
  # rc=$?; if [ $rc != 0 ]; then exit $rc; fi
  # TEST_STORE=cassandra sbt test
  # rc=$?; if [ $rc != 0 ]; then exit $rc; fi
  # TEST_STORE=mongo sbt test
  # rc=$?; if [ $rc != 0 ]; then exit $rc; fi
}

# Get command or default to 'default' value
CMD="${1-default}"

case "${CMD}" in
  all)
    clean
    build_ui
    build_manual
    build_server
    # test_server
    # build_cli
    ;;
  cli)
    build_cli
    ;;
  ui)
    build_ui
    ;;
  clean)
    clean
    ;;
  manual)
    manual
    ;;
  server)
    build_server
    ;;
  default)
    clean
    build_ui
    build_manual
    build_server
    test_server
    build_cli
    ;;
  *)
    echo "Unknown option ${CMD}"
    exit 1
esac

exit ${?}
