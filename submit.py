#!/usr/bin/env

import sys, os, glob,re 
from subprocess import check_call
from toposort import toposort

BASE_URL = "http://danielkza.duckdns.org:12532/rpms/"

dist = sys.argv[1]
dist_ver = sys.argv[2]

pkg_deps = {
    'perl-Test-BDD-Cucumber': {'perl-Number-Range'},
    'perl-Graph-ReadWrite': {'perl-Chart-Gnuplot'},
    'perl-Graph-Writer-DSM': {'perl-Graph-ReadWrite'},
    'analizo': {
        'perl-Test-BDD-Cucumber',
        'perl-Graph-Writer-DSM',
        'perl-FindBin-libs',
        'perl-File-Share',
        'doxyparse'
    }
}

pkg_batches = toposort(pkg_deps)

if dist == 'fedora' and int(dist_ver) >= 22:


for batch in :
    if dist == 'fedora'):
    pkgs = map(lambda p: sorted(glob.glob(p + "-*.src.rpm"))[-1], batch)
    urls = map(lambda p: BASE_URL + p, pkgs)
    check_call(['copr-cli', 'build', 'analizo'] + urls)


