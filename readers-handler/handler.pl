#!C:\Strawberry\perl\bin 
 
use DBI;
use Data::Printer;
use strict;
        
my $host = "localhost"; # MySQL-сервер нашего хостинга
my $port = "3306"; # порт, на который открываем соединение
my $user = "root"; # имя пользователя
my $pass = "1234567890"; # пароль
my $db = "skud"; # имя базы данных 

print "Content-type: text/html\n\n";

my $dbh = DBI->connect("DBI:mysql:$db:$host:$port",$user,$pass);
my $sth = $dbh->prepare("select * from events"); 
# готовим запрос
$sth->execute; # исполняем запрос

while ( my $ref = $sth->fetchrow_arrayref) {
print "$$ref[0]\t"; # печатаем результат
print "$$ref[1]\t"; # печатаем результат
print "$$ref[2]\t"; # печатаем результат
print "$$ref[3]\n"; # печатаем результат
} 

my $rc = $sth->finish;    
$rc = $dbh->disconnect;  # закрываемсоединение