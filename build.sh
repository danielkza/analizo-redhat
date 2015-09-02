#!/bin/bash

set -e

fedora_git_base="git://pkgs.fedoraproject.org/"
rpm_dir="$PWD/rpms"

deps=$(cat <<EOF | tr '\n' ' ' | tr -s ' '
perl-IO-TieCombine
perl-String-RewritePrefix
perl-Digest-JHash
perl-Hash-MoreUtils
perl-JSON-MaybeXS
perl-bareword-filehandles
perl-multidimensional
perl-strictures
perl-Moo
perl-MooX-Types-MooseLike
perl-MooX-Types-MooseLike-Numeric
perl-Test-Log-Dispatch
zeromq2,f22

perl-App-Cmd
perl-CHI
perl-Graph
perl-EV
perl-Mojolicious
perl-Statistics-Descriptive
perl-Term-ProgressBar
perl-ZeroMQ,f22

perl-Test-TempDir
perl-File-LibMagic
perl-Const-Fast
perl-Devel-Pragma
perl-Module-Install-ExtraTests
perl-B-Hooks-OP-Check-EntersubForCV
perl-Devel-BeginLift
perl-Method-Signatures

perl-Number-Range
perl-Test-BDD-Cucumber

perl-Chart-Gnuplot
perl-Graph-ReadWrite
perl-Graph-Writer-DSM

perl-File-Share
perl-FindBin-libs
EOF
)

if which dnf >/dev/null 2>&1; then
    repoquery="dnf repoquery -q"
    builddep="dnf builddep"
    yum="dnf"
else
    repoquery="repoquery"
    builddep="yum-builddep"
    yum="yum"
fi

check_built()
{
    local package="$1" version="$2"
    if [ -n "$($repoquery --whatprovides "$1")" ]; then
        echo "Package $1 already available, not building"
        return 1
    fi
    return 0
}

check_built_by_spec()
{
    local spec="$1"
    local packages=$(rpmspec -q "$spec") package ok=1

    for package in $packages; do
        if [ -z "$($repoquery "$package")" ]; then
            ok=0
            break
        fi
    done

    if [ $ok -eq 1 ]; then
        echo "Package $package already up-to-date, not building"
        return 1
    fi

    return 0
}

checkout_branch()
{
    local branch="$1"

    if [ -n "$branch" ]; then
        git checkout "$branch"
    else
        if [ "$ID" == "fedora" ]; then
            fedora_min_ver="$VERSION_ID"
        else
            fedora_min_ver="19"
        fi

        ok=0
        for fedora_ver in $(seq $fedora_min_ver 22); do
            # There's a stupid zeromq2 repository with a branch with no spec file
            if git checkout "f${fedora_ver}" && [ -f *.spec ]; then
                ok=1
                break
            fi
        done

        if [ $ok -ne 1 ]; then
            echo "Error: failed to find $package with suitable Fedora version"
            return 1
        fi
    fi

    return 0
}

download_sources_from_cache()
{
    local sources_file=$(readlink -f "$1")

    pushd build/SOURCES
    while read source_line; do
        IFS=' ' read md5 filename <<< "$source_line"
        curl -o "$filename" "http://pkgs.fedoraproject.org/repo/pkgs/$package/$filename/$md5/$filename"
    done < <(cat "$sources_file" | tr -s ' ')
    popd
}

download_sources_from_spec()
{
    # Download sources from spec file
    #
    # Remove anything after the first source line that isn't a source line.
    # This is dumb, but spectool can fail for some strange scripts, and we don't
    # really care about them as long as we can get the Source URL correctly.
    #
    #local spec_sources=$(sed -E -n -e '0,/^Source[0-9]*/p' -e '/^(Source|Patch)[0-9]*/p' "$1" | uniq)
    local spec_sources=$(cat $1)
    
    # Try the CPAN history if the main archive fails
    if ! spectool -C build/SOURCES/ -g - <<< "$spec_sources"; then
      echo "$spec_sources" | sed -E 's!(search\.cpan\.org/CPAN/|www\.cpan\.org/)!backpan.perl.org/!' | \
        spectool -C build/SOURCES/ -g -
    fi
}

build_package()
{
    local spec="$1"

    # We could use Mock here, but we'll assume you're building in a VM you don't
    # care too much about, to save time.
    sudo $builddep -y "$spec"
    rpmbuild -D "_topdir $PWD/build" -ba "$spec"
    chmod -R "ug=rwX,o=rX" build/RPMS/ build/SRPMS/
    rsync -av build/RPMS/ build/SRPMS/ "$rpm_dir"

    # Immediately add the package to the repo. Make sure any subsequent packages
    # to be built that might depend on what we've already built work.
    createrepo --update "$rpm_dir"
}

###

mkdir -p "$rpm_dir"
if ! [ -f "$rpm_dir/repodata/repomd.xml" ]; then
    createrepo "$rpm_dir"
fi

source /etc/os-release
    
pushd deps

for package in $deps; do
    IFS=',' read package branch <<< "$package"
    check_built "$package" || continue

    [ -e "$package" ] || git clone "${fedora_git_base}${package}.git"

    pushd "$package/"

    if [ -d .git ]; then
        checkout_branch "$branch"
    fi

    mkdir -p build/SOURCES/
    cp * build/SOURCES/ || :

    # Try to get sources from Fedora caches first
    if [ -f sources ]; then
        download_sources_from_cache sources
    else
        download_sources_from_spec *.spec
    fi
    
    build_package *.spec

    popd # $package
done

popd # deps

for package in doxyparse analizo; do
    pushd "$package/"

    check_built_by_spec *.spec || { popd; continue; }

    mkdir -p build/SOURCES/
    cp * build/SOURCES/ || :
    download_sources_from_spec *.spec

    build_package *.spec

    popd # package
done

sudo "$yum" -y install analizo
