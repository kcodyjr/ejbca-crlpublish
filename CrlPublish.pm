package EJBCA::CrlPublish;
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

my $globalOldConfigDir = '/etc/crlpublisher';
my $invokeOldConfigDir = $ENV{HOME} . '/.crlpublisher';
my $globalNewConfigDir = '/etc/crlpublish';
my $invokeNewConfigDir = $ENV{HOME} . '/.crlpublish';


###############################################################################
# Library Dependencies

use EJBCA::CrlPublish::Config;
use EJBCA::CrlPublish::CrlInfo;
use EJBCA::CrlPublish::Method;
use EJBCA::CrlPublish::Target;

our $VERSION = '0.3';


###############################################################################
# Configuration Loader

sub loadConfiguration() {

	EJBCA::CrlPublish::Config->importAllFiles( $globalNewConfigDir );
	EJBCA::CrlPublish::Config->importAllFiles( $globalOldConfigDir );
	EJBCA::CrlPublish::Config->importAllFiles( $invokeNewConfigDir );
	EJBCA::CrlPublish::Config->importAllFiles( $invokeOldConfigDir );

}


###############################################################################
# CRL Handler

sub processCrl($) {
	my $crlFile = shift;

	loadConfiguration();

	my $crlInfo = EJBCA::CrlPublish::CrlInfo->new( $crlFile );

	my @targets = EJBCA::CrlPublish::Target->find( $crlInfo );

	my $rc;
	my $rv = 0;
	foreach my $target ( @targets ) {
		# TODO: implement asynchronous queueing
		$rc = EJBCA::CrlPublish::Method->execute( $target );
		$rv = 1 unless $rc;
	}

	exit $rv;
}


###############################################################################
# Cron Despooler

sub processQueue() {

	loadConfiguration();

#	my $dir = $cfg->spooldirectory
#		or die "Asynchronous publishing is not configured.\n";

	# look through spooldirectory; push then remove

}


###############################################################################
####################################### EOF ###################################
###############################################################################
1;
