
help () {
  echo ""
  echo ">>> Usage of build.sh:"
  echo "   ./build.sh package_name version"
  echo " * e.g:"
  echo "   ./build.sh iain 1.0-6"
  echo "<<<"
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
    echo "Package folder not found: $(realpath $PACKAGE_NAME)"
    return 1
    fi
  PACKAGE_FOLDER=$(realpath $PACKAGE_NAME)

  if [[ -z $TARGET_VERSION ]]; then
    echo "Target version not provided"
    return 1
    fi






  if [[ $TARGET_VERSION == *"."* ]]; then
    if [[ $TARGET_VERSION == *"-"* ]]; then
      VERSION=(${TARGET_VERSION//-/ })
      UPSTREAM_VERSION=${VERSION[0]}
      DEB_VERSION=${VERSION[1]}
      unset VERSION
    else
      UPSTREAM_VERSION=$TARGET_VERSION
      DEB_VERSION="0"
      TARGET_VERSION="${UPSTREAM_VERSION}-${DEB_VERSION}"
      fi


    if [[ -n $UPSTREAM_VERSION ]];then
      echo " * Version OK"
    else
      echo " * Version NOT ok (should be x.x-x) / current: $TARGET_VERSION"
      return 1
      fi
  else
    echo " * Version NOT ok (should be x.x-x) / current: $TARGET_VERSION"
    return 1
    fi





  echo " * Target package: $PACKAGE_NAME at: $PACKAGE_FOLDER"
  echo " * Target version: $TARGET_VERSION / Upstream Version: $UPSTREAM_VERSION / Debian Version: $DEB_VERSION"





  echo " * Generating tarball..."
  TARBALL="./${PACKAGE_NAME}_${UPSTREAM_VERSION}.orig.tar.gz"
  rm $TARBALL
  tar -cz "./${PACKAGE_NAME}" -f $TARBALL || return 1
  echo " * Tarball generated: $TARBALL"


  echo " * Extracting tarball..."
  BUILD_FOLDER="./${PACKAGE_NAME}-${UPSTREAM_VERSION}"
  SRC_FOLDER="${BUILD_FOLDER}/src"
  if ! [[ -d $BUILD_FOLDER ]]; then mkdir $BUILD_FOLDER;fi;
  if ! [[ -d $SRC_FOLDER ]]; then mkdir $SRC_FOLDER;fi;

  tar -xzf $TARBALL -C $SRC_FOLDER --strip-components=2 || return 1
  echo " * Tarball extracted: $SRC_FOLDER"

  echo " * Copying debian..."
  cp -r "./debian" "$BUILD_FOLDER" || return 1
  echo " * Debian copied"

  echo " * Entering build folder: $BUILD_FOLDER"
  cd $BUILD_FOLDER || return 1



  if [[ -f "./debian/changelog" ]]; then

     if [[ $DEB_VERSION != "0" ]]; then
       echo " * Modifying changelog entry"
       dch -v $TARGET_VERSION
       else
         echo " * Adding changelog entry"
         dch -i
         fi
  else
    echo " * Writing new changelog"
    dch --create -v "${TARGET_VERSION}" -u low --package $PACKAGE_NAME
    fi
  cp "./debian/changelog" "$START_DIR/debian"


  return 0
}

START_DIR=$(pwd)

show_error () {
  # shellcheck disable=SC2164
  cd "$START_DIR"
  echo " * ERROR: build failed somewhere"
  help
  exit 1
}



if [[ $* == "--help" ]]; then
  help
else
  main "$@" || show_error
fi








