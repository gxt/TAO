#!/bin/bash

DIR_TMP=/tmp/$USER-gitrepo

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
			echo "Second parameter: linux/stable/TAO"
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

tao_env()
{
	case "$1" in
		clean)
			ls -l $DIR_TMP
			read -N 1 -p "Make sure delete $DIR_TMP (y/n)?"
			if [ $REPLY == y ]; then
				rm -fr $DIR_TMP
			fi
			go_with_exit welldone "$DIR_TMP is removed!"
			;;
		*)
			go_with_exit usage
	esac
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

		stable)
			if [ -d $STABLE_TEMP ]; then
				go_with_exit error "$STABLE_TEMP already exist!"
			fi
			if [ ! -d $LINUX_LOCAL ]; then
				go_with_exit error "$LINUX_LOCAL should exist!"
			fi

			git clone --mirror $LINUX_LOCAL -- $STABLE_TEMP
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
		linux)	go_with_exit error "NOT supported!" ;;
		stable)	go_with_exit error "NOT supported!" ;;

		TAO)
			if [ -d $TAO_TEMP ]; then
				go_with_exit error "$TAO_TEMP already exist!"
			fi
			if [ ! -d $TAO_LOCAL ]; then
				go_with_exit error "$TAO_LOCAL should exist!"
			fi
			git clone --mirror $TAO_LOCAL -- $TAO_TEMP
			cd $TAO_TEMP; git push $TAO_GITHUB master
			go_with_exit welldone "Push $TAO_LOCAL to $TAO_GITHUB"
			;;
		*)
			go_with_exit usage
	esac
}

PATCHDIR=~/patches/
PATCHVER=v5             # changed by time

c_oldgit()
{
	go_with_exit todo
	if [ $1 == "format-patch" ]; then
	    git format-patch --thread --cover-letter --subject-prefix=PATCH$PATCHVER    \
	        --output-directory $PATCHDIR/qemu-uc32-$PATCHVER                        \
	        --cc=blauwirbel@gmail.com                                               \
	        --cc=afaerber@suse.de                                                   \
	        --cc=chenwj@iis.sinica.edu.tw                                           \
	        master..unicore32
	    ./scripts/checkpatch.pl $PATCHDIR/qemu-uc32-$PATCHVER/*                     \
	        > $PATCHDIR/qemu-uc32-$PATCHVER/checkpatch

	elif [ $1 == "request-pull" ]; then
	    git request-pull master git://github.com/gxt/QEMU.git unicore32             \
	        > $PATCHDIR/qemu-uc32-$PATCHVER/request-pull

	elif [ $1 == "send-email" ]; then
	    shift
	    git send-email --from=gxt@mprc.pku.edu.cn                                   \
	        --to=qemu-devel@nongnu.org                                              \
	        --subject="[PULL] UniCore32 PUV3 machine support"                       \
	        --cc=blauwirbel@gmail.com                                               \
	        --cc=afaerber@suse.de                                                   \
	        --cc=chenwj@iis.sinica.edu.tw                                           \
	        --cc=gxt@mprc.pku.edu.cn                                                \
	        $@
	fi
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
	env)
		tao_env $2
		;;
	*)
		go_with_exit usage
esac

go_with_exit error "SHOULD not come here! Check script!"

