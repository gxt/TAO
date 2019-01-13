#!/bin/bash

DIR_TMP=/tmp/$USER

LINUX_GITHUB=https://github.com/torvalds/linux.git
LINUX_LOCAL=/pub/GIT-ORIGIN/linux/linux.git/
LINUX_TEMP=$DIR_TMP/linux.git

STABLE_KERNEL=git://git.kernel.org/pub/scm/linux/kernel/git/stable/linux-stable.git
STABLE_LOCAL=/pub/GIT-ORIGIN/linux/linux-stable.git/
STABLE_TEMP=$DIR_TMP/linux-stable.git
STABLE_VER=linux-4.9.y

TAO_GITHUB=git@github.com:gxt/TAO.git
TAO_LOCAL=/pub/GIT-MPRC/TAO.git
TAO_TEMP=$DIR_TMP/TAO.git

go_with_exit()
{
	case "$1" in
		welldone)
			echo "WELLDONE: " $2
			exit 0
			;;
		usage)
			echo "First parameter: clone/pull/push"
			echo "Second parameter: linux/linux-stable/TAO"
			echo "  clone: clone from web to temp"
			echo "  pull: clone from local, and pull from web to temp"
			echo "  push: clone from local, and push from temp to web"
			echo "Example: TAO-git.sh update linux"
			;;
		todo)
			echo "TODO: Not implemented or Not finished!"
			;;
		error)
			echo "ERROR: " $2
			;;
		*)
			echo "Command not found: $1"
	esac
	exit 1
}

c_clone()
{
	case "$1" in
		linux)
			if [ -d $LINUX_TEMP ]; then
				go_with_exit error "$LINUX_TEMP already exist!"
			fi

			git clone --mirror $LINUX_GITHUB -- $LINUX_TEMP
			go_with_exit welldone "Check $LINUX_TEMP"
			;;

		linux-stable)	# TODO
			go_with_exit todo
			if [ -d $STABLE_TEMP ]; then
				go_with_exit error "$STABLE_TEMP already exist!"
			fi
			if [ ! -d $LINUX_LOCAL ]; then
				go_with_exit error "$LINUX_LOCAL should exist!"
			fi

			git clone --mirror /pub/GIT-ORIGIN/linux/linux.git/ -- $STABLE_TEMP
			cd $STABLE_TEMP; git remote add -t $STABLE_VER $STABLE_VER $STABLE_KERNEL
			cd $STABLE_TEMP; git remote update $STABLE_VER
			go_with_exit welldone "Check $STABLE_TEMP"
			;;

		TAO)
			if [ -d $DIR_TMP/TAO.git ]; then
				go_with_exit error "$TAO_TEMP already exist!"
			fi
			git clone --mirror $TAO_GITHUB -- $TAO_TEMP
			go_with_exit welldone "Check $TAO_TEMP"
			;;
		*)
			go_with_exit usage
	esac
}

c_pull()
{
	case "$1" in
		TAO)
			go_with_exit todo
			if [ -d $TAO_TEMP ]; then
				go_with_exit error "$TAO_TEMP already exist!"
			fi
			if [ ! -d $TAO_LOCAL ]; then
				go_with_exit error "$TAO_LOCAL should exist!"
			fi

			git clone --mirror $TAO_LOCAL -- $TAO_TEMP
			go_with_exit welldone "Check $TAO_TEMP"
			;;
		*)
			go_with_exit usage
	esac
}

c_push()
{
	case "$1" in
		TAO)
			go_with_exit todo
			if [ -d $TAO_TEMP ]; then
				go_with_exit error "$TAO_TEMP already exist!"
			fi
			if [ ! -d $TAO_LOCAL ]; then
				go_with_exit error "$TAO_LOCAL should exist!"
			fi
			git clone --mirror $TAO_LOCAL -- $TAO_TEMP
			go_with_exit welldone "Push $TAO_LOCAL to $TAO_GITHUB"
			;;
		*)
			go_with_exit usage
	esac
}

if [ $# -ne 2 ]; then
	go_with_exit usage
fi

if [ ! -d $DIR_TMP ]; then
	mkdir -p $DIR_TMP
fi

case "$1" in
	clone)
		c_clone $2
		;;
	pull)
		c_pull $2
		;;
	push)
		c_push $2
		;;
	*)
		go_with_exit usage
esac

go_with_exit error "SHOULD not come here! Check script!"

