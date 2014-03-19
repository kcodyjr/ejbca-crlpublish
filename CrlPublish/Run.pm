package EJBCA::CrlPublish::Run;
use warnings;
use strict;
#
# crlpublish
#
# Copyright (C) 2014, Kevin Cody-Little <kcodyjr@gmail.com>
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
# Global Configuration

our $VERSION = '0.3';

my @runpath = split /\//, $0;
my $program = pop @runpath;


###############################################################################
# Forward Function Declarations

use EJBCA::CrlPublish;

sub usage();
sub version();


###############################################################################
# Argument Processing

if ( @ARGV == 0 ) {

	unless ( -t STDIN ) {
		EJBCA::CrlPublish::processQueue;
		exit -1; # should not return
	}

	usage;
	exit 0;
}

elsif ( @ARGV == 1 ) {

	if ( -f $ARGV[0] ) {	# called with a crl
		EJBCA::CrlPublish::processCrl( $ARGV[0] );
		exit -1; # should not return
	}

	elsif ( $ARGV[0] eq '-v' ) {
		version;
		exit 0;
	}

	elsif ( $ARGV[0] eq '-h' ) {
		usage;
		exit 0;
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
# copyright message

sub version() {
	print $program , ', version ', $VERSION, "\n";
	print q%
+-----------------------------------------------------------------------+
| Copyright (C) 2014, Kevin Cody-Little <kcodyjr@gmail.com>             |
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

%
}


###############################################################################
# usage message

sub usage() {
}


###############################################################################
####################################### EOF ###################################
###############################################################################
1;
