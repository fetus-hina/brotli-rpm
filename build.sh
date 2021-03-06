#!/bin/bash

set -eu

docker pull centos:7
docker pull centos:6

for i in 7 6; do
  rm -rf centos${i}.build
  make centos${i}
  find centos${i}.build -type f -name '*.rpm' | xargs ./sign.exp
  cp -f centos${i}.build/RPMS/x86_64/brotli-*.rpm /var/www/sites/fetus.jp/rpm.fetus.jp/public_html/el${i}/x86_64/brotli/
  createrepo /var/www/sites/fetus.jp/rpm.fetus.jp/public_html/el${i}/x86_64/

  cp -f centos${i}.build/SRPMS/brotli-*.rpm /var/www/sites/fetus.jp/rpm.fetus.jp/public_html/el${i}/src/brotli/
  createrepo /var/www/sites/fetus.jp/rpm.fetus.jp/public_html/el${i}/src/
done
