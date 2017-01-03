#!/usr/bin/perl

use CGI qw/:standard/;

print
           header,
           start_html('Simple Script'),
           h1('Simple Script'),
	hr,"\n";

if (param) {
           print
           "Your name is ",em(param('name')),p,
           "Your favorite color is ",em(param('color')),".\n";
	   open(my $fh, '>>', '/home/pi/fcgi/testing');
	   my $name = param('name');
	   my $color = param('color');

	   my $last_name = param('last_name');
	   my $first_name = param('first_name');
	   my $patronymic = param('patronymic');
	   my $post = param('post');
	   my $id_card = param('id_card');
	   my $reader_id = param('reader_id');
	   my $datetime = localtime();

	   print $fh "$datetime from $reader_id : $last_name | $first_name | $patronymic | $post | $id_card \n";
	   close $fh;	
        }
        print end_html;


