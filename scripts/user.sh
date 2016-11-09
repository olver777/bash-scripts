#!/bin/bash

nul=0
grep "$1" /etc/passwd >/dev/null
if [[ "$?" = $nul ]]
then
    echo "Користувач є в системі"
else
    echo "Даного користувача не має в системі"
fi
