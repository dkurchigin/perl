#!C:\Strawberry\perl\bin 
 
use DBI;
use Data::Printer;
use strict;
        
my $host = "localhost"; # MySQL-������ ������ ��������
my $port = "3306"; # ����, �� ������� ��������� ����������
my $user = "root"; # ��� ������������
my $pass = "1234567890"; # ������
my $db = "skud"; # ��� ���� ������ 

print "Content-type: text/html\n\n";

my $dbh = DBI->connect("DBI:mysql:$db:$host:$port",$user,$pass);
my $sth = $dbh->prepare("select * from events"); 
# ������� ������
$sth->execute; # ��������� ������

while ( my $ref = $sth->fetchrow_arrayref) {
print "$$ref[0]\t"; # �������� ���������
print "$$ref[1]\t"; # �������� ���������
print "$$ref[2]\t"; # �������� ���������
print "$$ref[3]\n"; # �������� ���������
} 

my $rc = $sth->finish;    
$rc = $dbh->disconnect;  # �������������������