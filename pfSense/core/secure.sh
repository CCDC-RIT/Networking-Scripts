#!/bin/sh

file_perms() {
    chattr +i /etc/ssh/sshd_config
    chattr +i /etc/rc_initial
    chattr +i /etc/inc/auth.inc
}

secure() {
    file_perms
}

secure