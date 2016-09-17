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
            my ($subnet, $bitmask) = split(/\//, $line);
            print "net - $subnet; mask - $bitmask";
			calcSubnet($subnet, $bitmask);
        }
        my ($address, $description) = split(" ", $line);
	    print "$address\n";
	    ping($address, $description);
    }
}

sub ping {
	if ($net->ping($_[0], 5)) {
		if ($show_connected == 1) {
			print "$_[0]($_[1])\t now is UP\n";
		}
    } else {
		if ($show_disconnected == 1) {
			print "$_[0]($_[1])\t now is DOWN\n";
		}
	}
}

sub calcSubnet {
	my ($first_octet, $second_octet, $third_octet, $fourth_octet) = split(/\./, $_[0]);
	
	my $pattern = 0b11111111111111111111111111111111;
	my $pattern_second_octet = 0b11111111000000000000000000000000;
	my $pattern_third_octet = 0b11111111111111110000000000000000;
	my $pattern_fourth_octet = 0b11111111111111111111111100000000;
	my $pattern_simple = 0b11111111;
	
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
	#printf ("%b - first oktet\n", $octets[0]);
	#printf ("%b - second oktet\n", $octets[1]);
	#printf ("%b - third oktet\n", $octets[2]);
	#printf ("%b - fourth oktet\n", $octets[3]);
	
	my $sum = 2 ** (8 - ($bitmask - 24));
	#if ($_[1] > 16 && $_[1] <= 24) {
	
	$fourth_octet = 0b00110001; ##здесь адрес из диапазона
	my @initial_address = ($first_octet, $second_octet, $third_octet, $fourth_octet);
	printf ("%d - current 4\n", $fourth_octet);
	$initial_address[3] = $initial_address[3] >> (32 - $bitmask);
	$initial_address[3] = $initial_address[3] << (32 - $bitmask);
	my @max_address = ($first_octet, $second_octet, $third_octet, $fourth_octet);
	$max_address[3] = $initial_address[3] + ($pattern_simple ^ $octets[3]);
	printf ("%d - initial 4\n", $initial_address[3]);
	printf ("%d - max 4\n", $max_address[3]);
	for (my $fourth = $initial_address[3]; $fourth <= $max_address[3]; $fourth = $fourth + 0b00000001) {
		printf ("%d - 4\n", $fourth);
	}
	
	
	
	#ping("", $description)
	#printf ("%b\.%b\.%b\.\n", $result_address[0], $result_address[1], $result_address[2]);
	
	#my $a = 0b10000011;
	#print "$a\n";
	#my $b = 0b00000001;
	#print "$b\n";
	#my $c = $a + $b;
	#printf("%b \n", $c);
}

print "Press any key";
my $goodbye = <STDIN>;
print "Bye";
