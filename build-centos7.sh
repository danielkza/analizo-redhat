#!/bin/sh

set -e

fedora_git_base="git://pkgs.fedoraproject.org/"
rpm_dir="$PWD/rpms"

dist_packages=$(cat <<EOF
perl-IO-TieCombine
perl-String-RewritePrefix
perl-Digest-JHash
perl-Hash-MoreUtils
perl-JSON-MaybeXS
perl-Moo
perl-MooX-Types-MooseLike
perl-MooX-Types-MooseLike-Base
perl-MooX-Types-MooseLike-Numeric
perl-Test-Log-Dispatch
zeromq2-devel

perl-App-Cmd
perl-CHI
perl-Graph
perl-Mojolicious
perl-Statistics-Descriptive
perl-Term-ProgressBar
perl-ZeroMQ

perl-Test-TempDir
perl-File-LibMagic
perl-Method-Signatures
EOF
)

sudo yum install -y git make automake gcc gcc-c++ rpmdevtools createrepo rsync

mkdir -p rpms deps-dist
createrepo rpms/

sudo tee /etc/yum.repos.d/analizo-local.repo >/dev/null <<EOF
[analizo-local]
name=Analizo Local Repository
baseurl=file://$rpm_dir
enabled=1
EOF

pushd deps-dist

IFS=$'\n'
for package in $dist_packages; do
    [ -e "$package" ] || git clone "${fedora_git_base}${package}.git"
    pushd "$package"
    echo "-- Entering $package"

    git checkout f19 || git checkout f20 || git checkout f21
    mkdir -p SOURCES

    sed -i 's|http://search.cpan.org/CPAN|http://backpan.perl.org|' *.spec

    sed -n -e '0,/Source[0-9]/p' -e '/Source[0-9]/p' *.spec | spectool -C SOURCES/ -g -
    sudo yum-builddep -y *.spec  
    rpmbuild -D "_topdir $PWD" -ba *.spec
    rsync -av RPMS/ SRPMS/ "$rpm_dir"

    chmod -R "ug=rwX,o=rX" "$rpm_dir"
    createrepo --update "$rpm_dir"

    popd
done
unset IFS

popd
