DESCRIPTION

wikileaks-mirror.pl is a Perl script, which returns either a working random Wikileaks mirror or a complete list of working mirrors.
It can write the list to a file and read from that again to prevent downtimes of the official Wikileaks Website.

OPTIONS:

	-l				print mirrorlist to stdout

	-lo <outfile> 	print mirrorlist to file

	-r				print random mirror from wikileaks website

	-ri <infile>	print random mirror from file 
	
	-m				set your own wikileaks mirror url (like http://www.wikileaks.de/Mirrors.html)

To redirect your website users to a random Wikileaks mirror, you can use this php code:

	$mirror = shell_exec('/path/to/wikileaks-mirror.pl -r');
	header('Loation: '.$mirror);

	Or from mirror file:

	$mirror = shell_exec('/path/to/wikileaks-mirror.pl -ri mirrors.txt');
	header('Location: '.$mirror);

[![Flattr this git repo](http://api.flattr.com/button/flattr-badge-large.png)](https://flattr.com/submit/auto?user_id=sqrt529&url=https://github.com/sqrt529/wikileaks-random-mirror&title=wikileaks-random-mirror&language=en_GB&tags=github&category=software)
