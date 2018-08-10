#!/bin/bash

# Blondie101010's basic shell script library system utility module.
# This currently includes OS detection and service control.

source /usr/local/lib/b101010.inc.sh

# avoid reincluding it for nothing
if [[ $b101010_system = 1 ]]; then     # script already included
	return 0
fi

b101010_system=1

# Run the system's init service controller.
serviceControl() {      # $1:operation, $2:unit, [$3:source filename for install]
	if [[ "$INIT_SYSTEM" = "" ]]; then
		initDetect
	fi

	case "$1" in
		start|stop|restart)
			case "$INIT_SYSTEM" in
				"openrc")
					rc-service $2 $1
				;;

				"systemd")
					systemctl $1 $2
				;;

				"sysv")
					/etc/init.d/$2 $1
				;;

				"sysv-service")
					service $2 $1
				;;
			esac
		;;

		install)
			TARGET_NAME=$INIT_DIR/$2

			if [[ "$INIT_SYSTEM" = "systemd" ]]; then
				TARGET_NAME="$TARGET_NAME.service"
			fi

			cp $3 $TARGET_NAME
		;;

		enable)
			case "$INIT_ENABLE" in
				rc-update)
					rc-update add $2
				;;

				systemd)
					systemctl enable $2
				;;

				chkconfig)
					chkconfig $2 on
				;;

				update-rc.d)
					update-rc.d $2 defaults
				;;

				ln)
					ln -s /etc/init.d/$2 /etc/defaults/.
				;;
			esac
		;;

		*) error "Invalid service operation ($1)."
		;;
	esac
}

# Detect OS and version (if applicable).  
# It currently can identify over a dozen of operating systems and distros.
#
# We set 2 variables: OS_NAME and OS_VER
osDetect() {
	# note that the OS_VER is not populated for most systems as of yet
	export OS_VER=""

	if [[ -f /etc/centos-release ]]; then
		export OS_NAME="CentOS"
		export OS_VER=`sed 's/^.*release //;s/\..*(.*$//' /etc/centos-release`
	elif [[ -f /etc/SuSE-release ]]; then
		export OS_NAME="SuSE"
	elif [[ -f /etc/redhat-release ]] || [[ -f /etc/redhat_version ]]; then
		export OS_NAME="RedHat"
	elif [[ -f /etc/fedora-release ]]; then
		export OS_NAME="Fedora"
	elif [[ -f /etc/slackware-release ]]; then
		export OS_NAME="Slackware"
	elif [[ -f /etc/mandrake-release ]]; then
		export OS_NAME="Mandrake"
	elif [[ -f /etc/yellowdog-release ]]; then
		export OS_NAME="YellowDog"
	elif [[ -f /etc/sun-release ]]; then
		export OS_NAME="SunOS"
	elif [[ -f /etc/gentoo-release ]]; then
		export OS_NAME="Gentoo"
	fi

	if [[ "$OS_VER" != "" ]]; then
		return
	fi

	# attempt general means of getting the version
	if [[ -f /etc/lsb-release ]]; then
		if [[ "$OS_NAME" = "" ]]; then
			export OS_NAME=$(grep DISTRIB_ID /etc/lsb-release | sed 's/^.*=//')
		fi

		export OS_VER=$(grep DISTRIB_RELEASE /etc/lsb-release | sed 's/^.*=//')
	elif [[ -f /etc/os-release ]]; then
		if [[ "$OS_NAME" = "" ]]; then
			export OS_NAME=$(grep -w ID /etc/os-release | sed 's/^.*=//')
		fi

		export OS_VER=$(grep VERSION_ID /etc/os-release | sed 's/^.*"\(.*\)"/\1/')
	else
		if [[ "$OS_NAME" = "" ]]; then
			export OS_NAME=$(uname -s)
		fi

		export OS_VER=$(uname -r)
	elif [[ -f /etc/debian_release ]] || [[ -f /etc/debian_version ]]; then
		# put here as it is a more generic detection and is found on many Debian children (less clear)
		if [[ "$OS_NAME" = "" ]]; then
			export OS_NAME="Debian"
		fi

		export OS_VER=$(cat /etc/debian_version)
	fi
}

# Detect what to use (rc-service, service, systemctl, etc) to control this system's services.
# We set 3 variables: INIT_DIR, INIT_SYSTEM, and INIT_ENABLE.  Note that we also call osDetect().
initDetect() {
	osDetect

	INIT_DIR=/etc/init.d

	type rc-service > /dev/null 2>&1

	if [[ $? == 0 ]]; then
		export INIT_SYSTEM=openrc
		export INIT_ENABLE=rc-update
		return
	fi

	type systemctl > /dev/null 2>&1

	if [[ $? == 0 ]]; then
		export INIT_DIR=/etc/systemd/system
		export INIT_SYSTEM=systemd
		export INIT_ENABLE=systemd
		return
	fi

	type service > /dev/null 2>&1
	if [[ $? == 0 ]]; then
		export INIT_SYSTEM=sysv-service
	else
		export INIT_SYSTEM=sysv
	fi

	type chkconfig > /dev/null 2>&1

	if [[ $? == 0 ]]; then
		export INIT_ENABLE=chkconfig
	else
		type update-rc.d > /dev/null 2>&1

		if [[ $? == 0 ]]; then
			export INIT_ENABLE=update-rc.d
		else
			export INIT_ENABLE=ln
		fi
	fi

	return
}
