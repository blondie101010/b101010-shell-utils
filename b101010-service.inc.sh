#!/bin/bash

# Blondie101010's basic shell script library system service utility module.

if [[ $b101010_service > 0 ]]; then     # script already included
        return 0
fi

source /usr/local/lib/b101010.inc.sh

# define version which is also used to know if the script was already included
b101010_service=1

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

# Detect what to use (rc-service, service, systemctl, etc) to control this system's services.
# We set 3 variables: INIT_DIR, INIT_SYSTEM, and INIT_ENABLE.
initDetect() {
        INIT_DIR=/etc/init.d

        type rc-service > /dev/null 2>&1

        if [[ $? == 0 ]]; then
                INIT_SYSTEM=openrc
                INIT_ENABLE=rc-update
                return
        fi

        type systemctl > /dev/null 2>&1

        if [[ $? == 0 ]]; then
                INIT_DIR=/etc/systemd/system
                INIT_SYSTEM=systemd
                INIT_ENABLE=systemd
                return
        fi

        type service > /dev/null 2>&1
        if [[ $? == 0 ]]; then
                INIT_SYSTEM=sysv-service
        else
                INIT_SYSTEM=sysv
        fi

        type chkconfig > /dev/null 2>&1

        if [[ $? == 0 ]]; then
                INIT_ENABLE=chkconfig
        else
                type update-rc.d > /dev/null 2>&1

                if [[ $? == 0 ]]; then
                        INIT_ENABLE=update-rc.d
                else
                        INIT_ENABLE=ln
                fi
        fi

        return
}
