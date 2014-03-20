package EJBCA::CrlPublish::Run;
use warnings;
use strict;
#
# crlpublish
#
# Copyright (C) 2014, Kevin Cody-Little <kcody@cpan.org>
#
# Portions derived from crlpublisher.sh, original copyright follows:
#
# Copyright (C) 2011, Branko Majic <branko@majic.rs>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
###############################################################################

=head1 NAME

EJBCA::CrlPublish::Run

=head1 SYNOPSIS

Implements the /usr/bin/crlpublish script.

=head1 PREFERRED INVOCATION

=head2 /usr/bin/crlpublish [arguments]

=head1 ALTERNATE INVOCATION

=head2 perl -e 'use EJBCA::CrlPublish::Run' [arguments]

=head1 DEVELOPER NOTES

Since it implements an executable script, this module must control the exit
value, and therefore would interrupt startup if included by "use" or
"require" in another program.

To publish from within another program, use EJBCA::CrlPublish instead.

=cut


###############################################################################
# Library Dependencies

use EJBCA::CrlPublish;

our $VERSION = '0.4';


###############################################################################
# Display Messages

{ # private lexicals begin
my @runpath = split /\//, $0;
my $program = pop @runpath;

sub version() {
	print $program , ', version ', $VERSION, "\n";
	print '
+-----------------------------------------------------------------------+
| Copyright (C) 2014, Kevin Cody-Little <kcody@cpan.org>                |
| Copyright (C) 2011, Branko Majic <branko@majic.rs>                    |
|                                                                       |
| This program is free software: you can redistribute it and/or modify  |
| it under the terms of the GNU General Public License as published by  |
| the Free Software Foundation, either version 3 of the License, or     |
| (at your option) any later version.                                   |
|                                                                       |
| This program is distributed in the hope that it will be useful,       |
| but WITHOUT ANY WARRANTY; without even the implied warranty of        |
| MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         |
| GNU General Public License for more details.                          |
|                                                                       |
| You should have received a copy of the GNU General Public License     |
| along with this program.  If not, see <http://www.gnu.org/licenses/>. |
+-----------------------------------------------------------------------+

'
}

sub usage() {
	print $program , ', version ', $VERSION, "\n";
	print <<EEOF
Usage: $program <crlFile>
       $program -q | -l | -v | -h

$program is a utility for publishing certificate revocation lists to their
issuing distribution points. If called with the path to a CRL file in either
DER or PEM format as its only argument, it will publish that CRL to one or
more target servers.

$program references configuration files to determine where to send any given
CRL, by what method to send it, and with what parameters. The configuration
file format and location is detailed in "man crlpublish".

$program is fully backwards compatible with the configuration files from
Branko Majik's crlpublisher.sh script version 0.1, in situ and as-is.

If no configuration files exist, $program will use the "scp" method, will
try to retrieve the publishing host, path, and filename from the CRL itself,
will use the default SSH private keys, and will use the same username on
the target as on the origin host.

(TODO) $program is capable of queuing CRLs for asynchronous transfer. If
called with the "-l" argument, $program will list the contents of the queue.
If called with "-q", $program will try to flush the contents of the queue.

Also, the queue will be flushed if $program is called with no arguments and
STDIN is not a terminal. This is for convenience in setting up cron jobs.

EEOF
}

} # private lexicals end


###############################################################################
# Command Line Processing

if ( @ARGV == 0 ) {

	unless ( -t STDIN ) {
		EJBCA::CrlPublish::processQueue;
		exit -1;	# should not return
	}

	usage;
	exit 0;
}

elsif ( @ARGV == 1 ) {

	if ( -f $ARGV[0] ) {	# called with a crl
		EJBCA::CrlPublish::publishCrl( $ARGV[0] );
		exit -1;	# should not return
	}

	elsif ( $ARGV[0] eq '-v' ) {
		version;
		exit 0;
	}

	elsif ( $ARGV[0] eq '-h' ) {
		usage;
		exit 0;
	}

	elsif ( $ARGV[0] eq '-q' ) {
		EJBCA::CrlPublish::processQueue;
		exit -1;	# should not return
	}

	else {
		usage;
		exit 1;
	}
}

else {
	usage;
	exit 1;
}


###############################################################################

=head1 AUTHOR

Kevin Cody-Little <kcody@cpan.org>

=cut


###############################################################################
####################################### EOF ###################################
###############################################################################
1;
