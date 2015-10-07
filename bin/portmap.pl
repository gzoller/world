#!/usr/bin/perl -wl

use JSON::PP;
use Data::Dumper;
use CGI qw();

my $c = CGI->new;
print "Content-type: text/plain\n\n";
if ('POST' eq $c->request_method ) {

	my $http      = $c->param("http");
	my $mongo     = $c->param("mongo");
	my $rabbit    = $c->param("rabbit");
	my $memcached = $c->param("memcached");

	my $harnessFile;
	open(my $fh, '<', "/var/www/html/harness.json");
	{
		local $/;
		$harnessFile = <$fh>;
	}
	close($fh);
	my $harness = decode_json $harnessFile;

	# Mongo
	my $mongouri = $$harness{"facilities"}{"storage"}{"mongoDB"}{"uris"}[0];
	$mongouri .= ":$mongo";
	$$harness{"facilities"}{"storage"}{"mongoDB"}{"uris"}[0] = $mongouri;

	# Memcached
	my $cacheuri = $$harness{"facilities"}{"cache"}{"memcached"}{"uris"}[0];
	$_ = $cacheuri;
	s/(.*\:)\d+/$1$memcached/;
	$$harness{"facilities"}{"cache"}{"memcached"}{"uris"}[0] = $_;

	# RabbitMQ
	$$harness{"facilities"}{"queue"}{"rabbitMQ"}{"port"} = $rabbit;

	# HTTP
	$$harness{"facilities"}{"http"}{"port"} = $http;

	my $jsonOut = encode_json (\%$harness);
	$jsonOut =~ s/HTTPPORT/$http/g;

	open(my $fh, '>', '/var/www/html/harness.json');
	print $fh $jsonOut;
	close $fh;
} else {
	print <<EndOfHTML;
<html><head><title>Perl Environment Variables</title></head>
<body>
<h1>Perl Environment Variables</h1>
EndOfHTML
	foreach $key (sort(keys %ENV)) {
	    print "$key = $ENV{$key}<br>\n";
	}
	print "</body></html>";
}