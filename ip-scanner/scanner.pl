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
	my $pattern_second_octet = 0b11111111000000000000000000000000;
	my $pattern_third_octet = 0b11111111111111110000000000000000;
	my $pattern_fourth_octet = 0b11111111111111111111111100000000;
	my $bitmask = $_[1];
	my $shift_mask_left = $pattern >> (32 - $bitmask);
	my $netmask = $shift_mask_left << $bitmask;
	$netmask = $netmask << (32 - ($bitmask * 2));
	printf("%b - netmask\n", $netmask);
	
	my @octets = (0b0, 0b0, 0b0, 0b0); 
	$octets[0] = $netmask >> 24;
	if ($_[1] > 8) {		
		$octets[1] = $netmask ^ $pattern_second_octet;
		$octets[1] = $octets[1] << 8;
		$octets[1] = $octets[1] >> 24;
		
		if ($_[1] > 16) {
			$octets[2] = $netmask ^ $pattern_third_octet;
			$octets[2] = $octets[2] << 16;
			$octets[2] = $octets[2] >> 24;
		}
		if ($_[1] > 24) {	
			$octets[3] = $netmask ^ $pattern_fourth_octet;
			$octets[3] = $octets[3] << 24;
			$octets[3] = $octets[3] >> 24;
		}
	} 
	printf ("%b - first oktet\n", $octets[0]);
	printf ("%b - second oktet\n", $octets[1]);
	printf ("%b - third oktet\n", $octets[2]);
	printf ("%b - fourth oktet\n", $octets[3]);
	
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
