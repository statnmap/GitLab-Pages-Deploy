#!/bin/sh

# Modified from https://github.com/marketplace/actions/gh-pages-deploy

set -e

# Which branch?
REPONAME=${CI_PROJECT_NAME}

# Which directory to artifacts
if [ -z "$INPUT_BUILD_DIR" ]; then
  INPUT_BUILD_DIR="public"
fi

# GHIO="${OWNER}.github.io"
# if [[ "$REPONAME" == "$GHIO" ]]; then
#   TARGET_BRANCH="master"
# else
TARGET_BRANCH="gh-pages"
# fi
# Custom branch in global variables : INPUT_BRANCH
if [ ! -z "$INPUT_BRANCH" ]; then
  TARGET_BRANCH=$INPUT_BRANCH
fi
# By branch or all directory is the website
if [ -z "$SITE_BY_BRANCH" ]; then
  SITE_BY_BRANCH="FALSE"
fi

# echo "### Started deploy to $GITHUB_REPOSITORY/$TARGET_BRANCH"
echo "### Started deploy to $TARGET_BRANCH"

# echo "Configuration:"
echo "- email: $GITLAB_USER_EMAIL"
echo "- build_dir: $INPUT_BUILD_DIR"
echo "- CI_SERVER_HOST: $CI_SERVER_HOST"
echo "- CI_PROJECT_PATH: $CI_PROJECT_PATH"
echo "- CI_SERVER_HOST: $CI_SERVER_HOST"
echo "- CI_COMMIT_BRANCH: $CI_COMMIT_BRANCH"
echo "- SITE_BY_BRANCH: $SITE_BY_BRANCH"
echo "- INPUT_BUILD_DIR: $INPUT_BUILD_DIR"
# echo "- cname: $INPUT_CNAME"
# echo "- Jekyll: $INPUT_JEKYLL"

# Prepare build_dir
BUILD_DIR=$INPUT_BUILD_DIR
BUILD_DIR=${BUILD_DIR%/} # remove the ending slash if exists
mkdir -p $HOME/build/$BUILD_DIR
cp -R $BUILD_DIR/* $HOME/build/$BUILD_DIR/
# Retrieve gitlab-ci.yml in build
cp .gitlab-ci.yml $HOME/build


# Create or clone the gh-pages repo in a subdirectory named branch
mkdir -p $HOME/branch/
cd $HOME/branch/
git config --global user.name "$GITLAB_USER_LOGIN"
git config --global user.email "$GITLAB_USER_EMAIL"

if [ -z "$(git ls-remote --heads https://gitlab-ci-token:${CI_JOB_TOKEN}@${CI_SERVER_HOST}/${CI_PROJECT_PATH}.git ${TARGET_BRANCH})" ]; then
  echo "Create branch '${TARGET_BRANCH}'"
  git clone --quiet https://gitlab-ci-token:${CI_JOB_TOKEN}@${CI_SERVER_HOST}/${CI_PROJECT_PATH}.git ${TARGET_BRANCH} > /dev/null
  cd $TARGET_BRANCH
  git checkout --orphan $TARGET_BRANCH
  git rm -rf .
  echo "${CI_PROJECT_NAME}" > README.md
  git add README.md
  git commit -a -m "Create '$TARGET_BRANCH' branch"
  git push origin $TARGET_BRANCH
  cd ..
else
  echo "Clone branch '${TARGET_BRANCH}'"
  # git clone --quiet --branch=$TARGET_BRANCH https://${GITHUB_ACTOR}:${CI_JOB_TOKEN}@github.com/${GITHUB_REPOSITORY}.git $TARGET_BRANCH > /dev/null
  git clone --quiet --branch=$TARGET_BRANCH https://gitlab-ci-token:${CI_JOB_TOKEN}@${CI_SERVER_HOST}/${CI_PROJECT_PATH}.git ${TARGET_BRANCH} > /dev/null
fi


cd $HOME/branch/
# Sync repository with build_dir
cp -R $TARGET_BRANCH/.git $HOME/build/$BUILD_DIR/.git

if [[ $SITE_BY_BRANCH == "true" || $SITE_BY_BRANCH == "TRUE" ]]; then
  # site in dedicated directory in "public"
  rm -rf $TARGET_BRANCH/$INPUT_BUILD_DIR/$CI_COMMIT_BRANCH
  rm -rf $TARGET_BRANCH/.??*
  mkdir $TARGET_BRANCH/$INPUT_BUILD_DIR/$CI_COMMIT_BRANCH
  echo "Clean directory '$CI_COMMIT_BRANCH' only and git stuff"
else
  # site at the root directory
  # rm -rf $TARGET_BRANCH/$INPUT_BUILD_DIR/*
  rm -rf $TARGET_BRANCH/*
  rm -rf $TARGET_BRANCH/.??*
  mkdir $TARGET_BRANCH/$INPUT_BUILD_DIR
  echo "Removed all files"
fi

# Set git stuff
cp -R $HOME/build/$BUILD_DIR/.git $TARGET_BRANCH/.git
# Copy gitlab-ci.yml
cp $HOME/build/.gitlab-ci.yml $TARGET_BRANCH/

if [[ $SITE_BY_BRANCH == "true" || $SITE_BY_BRANCH == "TRUE" ]]; then
  # Copy files
  cd $HOME/branch/$TARGET_BRANCH/$INPUT_BUILD_DIR/$CI_COMMIT_BRANCH
  # Create home page index.html in public
INDEX=`ls -1 $HOME/branch/$TARGET_BRANCH/$INPUT_BUILD_DIR | sed "s/^.*/      <li\>\<a\ href=\"&\"\>&\<\\/a\>\<\\/li\>/"`
echo "<html>
  <head><title>Index of branch directories</title></head>
  <body>
    <h2>Index of branch directories</h2>
    <hr>
    <ui>
$INDEX
    <ui>
  </body>
</html>" > $HOME/branch/$TARGET_BRANCH/$INPUT_BUILD_DIR/index.html

else
  # Copy files
  # cd $TARGET_BRANCH/$INPUT_BUILD_DIR
  cd $HOME/branch/$TARGET_BRANCH/$INPUT_BUILD_DIR
fi

cp -Rf $HOME/build/$BUILD_DIR/* .

# Custom domain
# if [ ! -z "$INPUT_CNAME" ]; then
#   echo "$INPUT_CNAME" > CNAME
# fi

# Custom commit message
if [ -z "$INPUT_COMMIT_MESSAGE" ]
then
  INPUT_COMMIT_MESSAGE="$GITLAB_USER_LOGIN published a site update"
fi

# .nojekyll
if [ "$INPUT_JEKYLL" != "yes" ]; then
  touch $HOME/branch/$TARGET_BRANCH/.nojekyll
fi

# Deploy/Push (or not?)
cd $HOME/branch/$TARGET_BRANCH
if [ -z "$(git status --porcelain)" ]; then
  result="Nothing to deploy"
else
  git add -Af .
  git commit -m "$INPUT_COMMIT_MESSAGE"
  git push -fq origin $TARGET_BRANCH > /dev/null
  # push is OK?
  if [ $? = 0 ]
  then
    result="Deploy succeeded"
  else
    result="Deploy failed"
  fi
fi

# Clean directories
cd $HOME
rm -rf $HOME/build
rm -rf $HOME/branch

# Set output
echo $result
echo "::set-output name=result::$result"

echo "### Finished deploy"
