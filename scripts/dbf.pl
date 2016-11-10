#!/usr/bin/perl -w

sub kursy {
#    $val = $_[0];
    $date = `cat /mnt/t/nbumail_in/NBU/VAL*|iconv -f CP866 -t UTF8 -|grep Установити|awk '{print \$4}'|gawk -F\/ '{print \$3\$2\$1}'`;
#    $val_abbr = `cat /data/nbumail_in/NBU/VAL*|grep $val|awk '{print \$2}'`;
    $val_abbr = $_[0];
    $val = `cat /mnt/t/nbumail_in/NBU/VAL*|grep $val_abbr|awk '{print \$1}'`;
    $val_sum  = `cat /mnt/t/nbumail_in/NBU/VAL*|grep $val_abbr|awk '{print \$3}'`;
    $val_kurs = `cat /mnt/t/nbumail_in/NBU/VAL*|grep $val_abbr|awk '{print \$NF}'|sed s/-/./`;
use XBase;
$table = new XBase "/mnt/f/pfb/VAL1/KL_V030.DBF" or die XBase->errstr;
$input_rec = $table->last_record;
$table->set_record ($input_rec+1, $date, $val, $val_abbr, $val_sum, $val_kurs);
}
@kurs_dbf = (RUB,GBP,USD,EUR);
foreach (@kurs_dbf) {
kursy($_);
}