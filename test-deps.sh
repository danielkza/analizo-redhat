#!/bin/bash

get_spec() {
  cd "$1"
  local specs=(*.spec)
  echo "${specs[0]}"
}

for spec_dir in "$@"; do
    spec="$spec_dir/$(get_spec "$spec_dir")"

    echo "-- Package: $(rpmspec -q --queryformat "%{NAME}\n" "$spec")"

    IFS=$'\n'
    for req in $(rpmspec -q --requires "$spec"); do
        if [ -z "$(repoquery --whatprovides "$req")" ]; then 
            echo "Unsatisfied Requires: $req"
        fi
    done

    for req in $(rpmspec -q --buildrequires "$spec"); do
        if [ -z "$(repoquery --whatprovides "$req")" ]; then 
            echo "Unsatisfied BuildRequires: $req"
        fi
    done
    unset IFS
done
    

