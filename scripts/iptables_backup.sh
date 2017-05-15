#!/bin/bash

#################################################################################
# Резервне копіювання стартових правил фаєрволу та їх оновлення новими          #
# правилами. Даний скрипт виконується після внесення змін в правила фаєрволу,   #
# для того щоб вони збереглися після перезавантаження операційної системи.      #
#                                                                               #
# Автор:   Верхоламов Олег                                                      #
# Версія:  2.0                                                                  #
# Дата:    13.05.2017                                                           #
#################################################################################

# Задаємо константи
STARTUP_RULES_DIR="/etc"
STARTUP_RULES_FILE_NAME="iptables.up.rules"
BACKUP_DIR="$HOME/backups/iptables"

# Отримуємо значення поточної дати
date=`date '+%Y%m%d'`

# Функція оновлення правил фаєрволу
iptables_update ()
{
# Зберігаємо поточні стартові налаштування фаєрволу
cp -f -p $STARTUP_RULES_DIR/$STARTUP_RULES_FILE_NAME $BACKUP_DIR/$date/$STARTUP_RULES_FILE_NAME > /dev/null 2>&1
echo
echo -e "Поточні стартові налаштування фаєрволу збережено в файлі \e[32m$STARTUP_RULES_FILE_NAME\e[0m за адресою \e[32m$BACKUP_DIR/$date\e[0m"
echo

# Зберігаємо нові налаштуваня
iptables-save > $BACKUP_DIR/iptales_$date

# Оновлюємо стартові правила фаєрволу
cp -f -p $BACKUP_DIR $STARTUP_RULES_DIR/$STARTUP_RULES_FILE_NAME > /dev/null 2>&1
chown root:root $STARTUP_RULES_DIR/$STARTUP_RULES_FILE_NAME
chmod 400 $STARTUP_RULES_DIR/$STARTUP_RULES_FILE_NAME
echo
echo -e "Оновлено стартові налаштування фаєрволу в файлі \e[32m$STARTUP_RULES_FILE_NAME\e[0m що знаходиться за адресою \e[32m$STARTUP_RULES_DIR\e[0m"
echo
}

# Перевіряємо чи скрипт запущений від користувача з правами ROOT
if [[ $EUID -ne 0 ]]
then
    echo
    echo -e "\e[31mДаний скрипт повинен запускатися від користувача з правами ROOT\e[0m"
    echo
    exit 1
fi

# Перевіряємо чи існує файл зі стартовими налаштуваннями фаєрволу
if ! [[ -f "$STARTUP_RULES_DIR/$STARTUP_RULES_FILE_NAME" ]]
then
    echo
    echo -e "\e[31mФайлу зі стандартними налаштуваннями не існує, його буде створено\e[0m"
    echo
    touch /etc/iptables.up.rules > /dev/null 2>&1
fi

# Перевіряємо чи існує директорія для зберігання резервних копій
if ! [[ -d "$BACKUP_DIR" ]]
then
    echo
    echo -e "\e[31mДиректорія для збереження резервних копій не існує, її буде створено\e[0m"
    echo
    mkdir -p "$BACKUP_DIR" > /dev/null 2>&1
    iptables_update
else
    iptables_update
fi

exit 0






