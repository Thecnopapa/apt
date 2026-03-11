
help () {
  echo " * Usage:"
  echo "   ./build.sh package_name version"
  echo " * e.g:"
  echo "   ./build.sh iain 1.0-6"
  exit 1
}

main () {
  echo " * Building new package setup..."

  PACKAGE_NAME=$1
  TARGET_VERSION=$2


  if [[ -z $PACKAGE_NAME ]]; then
    echo "Package name not provided"
    return 1
  fi
  if ! [[ -d $PACKAGE_NAME ]]; then
    echo "Package folder does not found: $(realpath $PACKAGE_NAME)"
    return 1
  fi
  PACKAGE_FOLDER=$(realpath $PACKAGE_NAME)

  if [[ -z $TARGET_VERSION ]]; then
    echo "Target version not provided"
    return 1
  fi






  if [[ $TARGET_VERSION == *"."* ]] && [[ $TARGET_VERSION == *"-"* ]] ; then
    echo " * Version OK"
  else
    echo " * Version NOT ok (should be x.x-x) / current: $TARGET_VERSION"
    return 1
  fi

  VERSION=(${TARGET_VERSION//-/ })
  UPSTREAM_VERSION=${VERSION[0]}
  DEB_VERSION=${VERSION[1]}



  echo " * Target package: $TARGET_PACKAGE at: $PACKAGE_FOLDER"
  echo " * Target version: $TARGET_VERSION / Upstream Version: $UPSTREAM_VERSION / Debian Version: $DEB_VERSION"





  echo " * Generating tarball..."
  TARBALL="./${PACKAGE_NAME}_${UPSTREAM_VERSION}.orig.tar.gz"
  tar -cz "./${PACKAGE_NAME}" -f $TARBALL || exit 1
  echo " * Tarball generated: $TARBALL"


  echo " * Extracting tarball..."
  BUILD_FOLDER="./${PACKAGE_NAME}_${UPSTREAM_VERSION}"
  mkdir $BUILD_FOLDER || echo "Delete previous folder with same version to continue" && exit 1
  tar -xzf $TARBALL -C $BUILD_FOLDER --strip-components=1 || exit 1
  echo " * Tarball extracted: $BUILD_FOLDER"



  cd "$PACKAGE_FOLDER/../" || exit 1

  #tar -cz . -f iain1.orig.tar.gz

  return 0
}

if [[ $* == "--help" ]]; then
  help
else
  main "$@" || help
fi








