#!/bin/sh

file_perms() {
    chflags schg /etc/ssh/sshd_config
    chflags schg /etc/rc.initial
    chflags schg /etc/inc/auth.inc
}

secure() {
    file_perms
}

secure