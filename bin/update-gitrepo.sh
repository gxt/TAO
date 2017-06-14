#/bin/bash

echo "linux.git"
git clone --mirror https://github.com/torvalds/linux.git

echo "linux-stable.git"
git clone --mirror /pub/GIT-ORIGIN/linux/linux.git/ -- linux-stable.git
cd linux-stable.git
git remote add -t linux-4.9.y linux-stable git://git.kernel.org/pub/scm/linux/kernel/git/stable/linux-stable.git
git remote update linux-stable

