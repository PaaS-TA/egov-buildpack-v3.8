rm -rf ./build
bundle exec rake clean package OFFLINE=true PINNED=true
cf delete-buildpack test -f
cf create-buildpack test ./build/egov-buildpack-offline-3.8.zip 15


