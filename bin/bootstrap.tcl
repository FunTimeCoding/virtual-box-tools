#!/usr/bin/expect

set host [lindex $argv 0];
set user_password [lindex $argv 1];
set root_password [lindex $argv 2];
set public_key [lindex $argv 3];

spawn ssh -o StrictHostKeyChecking=no $host
expect "password:"

set user_prompt {\$ $}

send "$user_password\n"
expect -re $user_prompt

send "mkdir -p .ssh\n"
expect -re $user_prompt

send "echo '$public_key' >> .ssh/authorized_keys\n"
expect -re $user_prompt

send "su - root\n"
expect "Password:"

send "$root_password\n"
expect ":~#"

send "mkdir -p .ssh\n"
expect ":~#"

send "echo '$public_key' >> .ssh/authorized_keys\n"
expect ":~#"

send "exit\n"
expect -re $user_prompt

send "exit\n"
expect eof
