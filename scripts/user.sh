#!/bin/bash

nul=0
grep "$1" /etc/passwd >/dev/null
if [[ "$?" = $nul ]]
then
    echo "���������� � � ������"
else
    echo "������ ����������� �� �� � ������"
fi
