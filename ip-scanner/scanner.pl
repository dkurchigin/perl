#!C:\Strawberry\perl\bin 

use strict;
use Net::Ping;

my $config_file = "ip_list";

my $echo_number = 3;
my $time_out = 10; 
my $show_connected = 1;
my $show_disconnected = 1;

#read params
my $view = @ARGV;

#parsing the list of parameters
for (my $i=0; $i <= $#ARGV; $i++) {
    my ($command, $value) = split(/=/, $ARGV[$i]); 
    #change viev-mod for addresses
    if ($command eq "-v") {
        if ($value eq "only_up") {
	        $show_connected = 1;
	        $show_disconnected = 0;
	    } elsif ($value eq "only_down") {
	        $show_connected = 0;
	        $show_disconnected = 1;
	    } else {
	        print "Unknown argument for -v option\n";
	    }
    }
    #change path to config
    if ($command eq "-c") {
        $config_file = $value;
    }
    #echo count
    if ($command eq "-e") {
	    $echo_number = $value;
    }
    #set timeout
    if ($command eq "-t") {
	    $time_out = $value;
    }
}

#hash for the address list
my %addresses;
open(CONFIG, $config_file) or die "Can't open file - $config_file!\n";
my $net = Net::Ping->new("icmp");
#read line by line
while (my $line = <CONFIG>) {
    #ignore lines with comments
    if ($line !~ /^#/) {
        #find subnet
        if ($line =~ /.\//) {
            print "SUBNET THERE $line";
            my ($subnet, $bitmask) = split("\/", $line);
            print "net - $subnet; mask - $bitmask";
			calcSubnet($subnet, $bitmask);
        }
        my ($address, $description) = split(" ", $line);
	    print "$address\n";
	    #ping($address, $description);
    }
}

sub ping {
	if ($net->ping($_[0], 5)) {
        print "$_[0]($_[1]) now is UP\n";
    }
}

sub calcSubnet {
	my ($first_octet, $second_octet, $third_octet, $fourth_octet) = split("\.", $_[0]);
	my @basic_address = ($first_octet, $second_octet, $third_octet, $fourth_octet);
	
	my $pattern = 0b11111111111111111111111111111111;
	my $bitmask = $_[1];
	my $shift_left = $pattern >> (32 - $bitmask);
	my $netmask = $shift_left << $bitmask;
	printf("%b - netmask\n", $netmask);
	
	my @swap = (0b0, 0b0, 0b0, 0b0);
	my $shift = 0; 
	if ($_[1] > 8 && $_[1] <= 16) {
		$shift = 16;
	} 
	$swap[0] = $netmask >> $shift;
	printf ("%b - oktet\n", $swap[0]);
	
	#my $a = $_[0];
	#print "$a\n";
	#my $b = $_[1];
	#print "$b\n";
	#my $c = $_[0] | $_[1];
	#printf("%b \n", $c);
}

print "Press any key";
my $goodbye = <STDIN>;
print "Bye";
