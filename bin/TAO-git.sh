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

UC32_GITHUB=git@github.com:gxt/UniCore32.git
UC32_LOCAL=/pub/GIT-MPRC/UniCore32.git
UC32_TEMP=$DIR_TMP/UniCore32.git

tao_exit()
{
	case "$1" in
		welldone)
			echo -e "\nWELLDONE: " $2
			exit 0
			;;
		usage)
			echo -e "\nTwo parameters needed, supported commands:"
			echo -e "  TAO-git.sh clone TAO"
			echo -e "  TAO-git.sh clone UC32"
			echo -e "  TAO-git.sh clone linux"
			echo -e "  TAO-git.sh clone stable"
			echo -e "  TAO-git.sh pull TAO"
			echo -e "  TAO-git.sh pull UC32"
			echo -e "  TAO-git.sh pull linux"
			echo -e "  TAO-git.sh pull stable"
			echo -e "  TAO-git.sh push TAO"
			echo -e "  TAO-git.sh push UC32"
			echo -e "  TAO-git.sh env clean"
			;;
		todo)
			echo -e "\nTODO: Not implemented or Not finished!"
			;;
		error)
			echo -e "\nERROR: " $2
			;;
		*)
			echo -e "\nCommand not found: $1"
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
			tao_exit welldone "$DIR_TMP is removed!"
			;;
		*)
			tao_exit usage
	esac
}

git_clone()
{
	case "$1" in
		linux)
			if [ -d $LINUX_TEMP ]; then
				tao_exit error "$LINUX_TEMP already exist!"
			fi

			git clone --mirror $LINUX_GITHUB -- $LINUX_TEMP
			tao_exit welldone "Check $LINUX_TEMP"
			;;

		stable)
			if [ -d $STABLE_TEMP ]; then
				tao_exit error "$STABLE_TEMP already exist!"
			fi
			if [ ! -d $LINUX_LOCAL ]; then
				tao_exit error "$LINUX_LOCAL should exist!"
			fi

			git clone --mirror $LINUX_LOCAL -- $STABLE_TEMP
			cd $STABLE_TEMP; git remote add -t $STABLE_VER $STABLE_VER $STABLE_KERNEL
			cd $STABLE_TEMP; git remote update $STABLE_VER
			tao_exit welldone "Check $STABLE_TEMP"
			;;

		TAO)
			if [ -d $TAO_TEMP ]; then
				tao_exit error "$TAO_TEMP already exist!"
			fi
			git clone --mirror $TAO_GITHUB -- $TAO_TEMP
			tao_exit welldone "Check $TAO_TEMP"
			;;

		UC32)
			if [ -d $UC32_TEMP ]; then
				tao_exit error "$UC32_TEMP already exist!"
			fi
			git clone --mirror $UC32_GITHUB -- $UC32_TEMP
			tao_exit welldone "Check $UC32_TEMP"
			;;
		*)
			tao_exit usage
	esac
}

git_pull()
{
	case "$1" in
		linux)
			if [ -d $LINUX_TEMP ]; then
				tao_exit error "$LINUX_TEMP already exist!"
			fi
			if [ ! -d $LINUX_LOCAL ]; then
				tao_exit error "$LINUX_LOCAL should exist!"
			fi

			cp -a $LINUX_LOCAL $LINUX_TEMP
			cd $LINUX_TEMP; git remote update origin
			tao_exit welldone "Check $LINUX_TEMP"
			;;

		stable)
			if [ -d $STABLE_TEMP ]; then
				tao_exit error "$STABLE_TEMP already exist!"
			fi
			if [ ! -d $STABLE_LOCAL ]; then
				tao_exit error "$STABLE_LOCAL should exist!"
			fi

			cp -a $STABLE_LOCAL $STABLE_TEMP
			cd $STABLE_TEMP; git remote update $STABLE_VER
			tao_exit welldone "Check $STABLE_TEMP"
			;;

		TAO)
			if [ -d $TAO_TEMP ]; then
				tao_exit error "$TAO_TEMP already exist!"
			fi
			if [ ! -d $TAO_LOCAL ]; then
				tao_exit error "$TAO_LOCAL should exist!"
			fi

			cp -a $TAO_LOCAL $TAO_TEMP
			cd $TAO_TEMP; git remote update origin
			tao_exit welldone "Check $TAO_TEMP"
			;;

		UC32)
			if [ -d $UC32_TEMP ]; then
				tao_exit error "$UC32_TEMP already exist!"
			fi
			if [ ! -d $UC32_LOCAL ]; then
				tao_exit error "$UC32_LOCAL should exist!"
			fi

			cp -a $UC32_LOCAL $UC32_TEMP
			cd $UC32_TEMP; git remote update origin
			tao_exit welldone "Check $UC32_TEMP"
			;;
		*)
			tao_exit usage
	esac
}

git_push()
{
	case "$1" in
		linux)	tao_exit error "NOT supported!" ;;
		stable)	tao_exit error "NOT supported!" ;;

		TAO)
			if [ -d $TAO_TEMP ]; then
				tao_exit error "$TAO_TEMP already exist!"
			fi
			if [ ! -d $TAO_LOCAL ]; then
				tao_exit error "$TAO_LOCAL should exist!"
			fi
			git clone --mirror $TAO_LOCAL -- $TAO_TEMP
			cd $TAO_TEMP; git push $TAO_GITHUB master
			tao_exit welldone "Push $TAO_LOCAL to $TAO_GITHUB"
			;;

		UC32)
			if [ -d $UC32_TEMP ]; then
				tao_exit error "$UC32_TEMP already exist!"
			fi
			if [ ! -d $UC32_LOCAL ]; then
				tao_exit error "$UC32_LOCAL should exist!"
			fi
			git clone --mirror $UC32_LOCAL -- $UC32_TEMP
			cd $UC32_TEMP; git push $UC32_GITHUB master
			tao_exit welldone "Push $UC32_LOCAL to $UC32_GITHUB"
			;;
		*)
			tao_exit usage
	esac
}

PATCHDIR=~/patches/
PATCHVER=v5             # changed by time

git_oldgit()
{
	tao_exit todo
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
	tao_exit usage
fi

if [ ! -d $DIR_TMP ]; then
	mkdir -p $DIR_TMP
fi

case "$1" in
	clone)
		git_clone $2
		;;
	pull)
		git_pull $2
		;;
	push)
		git_push $2
		;;
	env)
		tao_env $2
		;;
	*)
		tao_exit usage
esac

tao_exit error "SHOULD not come here! Check script!"

