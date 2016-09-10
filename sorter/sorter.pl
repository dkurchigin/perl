#!C:\Strawberry\perl\bin 

use strict;
use File::Copy;

#Declare variables for the destination directory and file extensions
my $download_dir = 'C:\Users\Kurchigin-DV\Downloads';
my $SORTING_dir = "$download_dir\\SORTING";
my @extension = ('jpg', 'png', 'gif', 'pdf', 'exe'); 

#Check directory exists - if not, create
if (-e $SORTING_dir && -x $SORTING_dir && -d $SORTING_dir) {
	print "Directory is there\n";
} else {
	mkdir "$download_dir\\SORTING";
	print "Directory $download_dir\\SORTING was created!\n";
}

#Open directories
opendir (S_DIR, $download_dir) or die $!;
opendir (D_DIR, $SORTING_dir) or die $!;

#Read files from directory
while(my $fname = readdir S_DIR) {
    my $path_to_file = "$download_dir\\$fname";
	#Parse files by extension
	for (my $i = 0; $i <= $#extension; $i++) {
		if ($fname =~ /$\.$extension[$i]/) {
			#If directory is directory && available && exist
			if (-e "$SORTING_dir\\$extension[$i]" && -x "$SORTING_dir\\$extension[$i]" && -d "$SORTING_dir\\$extension[$i]") {
				copy("$download_dir\\$fname", "$SORTING_dir\\$extension[$i]");
				if (-e "$SORTING_dir\\$extension[$i]\\$fname") {
					unlink ("$download_dir\\$fname");
				} else {
					print "Can't copy $fname\n";
				}
				print "Move $fname to $extension[$i]-folder\n";
			} else {
				mkdir "$SORTING_dir\\$extension[$i]";
				print "Directory $SORTING_dir\\$extension[$i] was created!\n";
			}
		}
	}
}

#Close all folders
closedir D_DIR;
closedir S_DIR;
