package EJBCA::CrlPublish;
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

EJBCA::CrlPublish

=head1 SYNOPSIS

High level API for publishing new CRLs.

Exports: &publishCrl &processQueue

=cut


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

our $VERSION = '0.50';

use base 'Exporter';
our @EXPORT = qw( publishCrl processQueue );


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

sub _publishOneCrl($) {
	my $crlFile = shift;

	my $crlInfo = EJBCA::CrlPublish::CrlInfo->new( $crlFile );

	my @targets = EJBCA::CrlPublish::Target->find( $crlInfo );

	my $rc = 1;
	foreach my $target ( @targets ) {
		# TODO: implement asynchronous queueing
		$rc &&= EJBCA::CrlPublish::Method->execute( $target );
	}

	return $rc;
}

=head1 CRL PUBLISHING FUNCTION

=head2 publishCrl( $crlFile );

=head2 publishCrl( @crlFiles );

Publishes the given CRL file, which must be a readable plain file, and
must be a valid certificate revocation list in PEM or DER format.

Supplying a list of crlFile names is supported, but only recommended when
asynchronous publishing is in use. Otherwise, the caller will not be able to
tell which CRL might have failed, and will have to republish them all.

Returns true if all supplied crlFiles were published or queued successfully,
and returns false if any single crlFile failed to publish or enqueue.

=cut

sub publishCrl(@) {

	loadConfiguration();

	my $rc = 1;
	while ( my $crlFile = shift ) {
		$rc &&= _publishOneCrl( $crlFile );
	}

	return $rc;
}


###############################################################################
# Cron Despooler

=head1 QUEUE FLUSH FUNCTION

=head2 processQueue();

Examines the local spool directory and attempts to push any pending CRL
updates to their destinations. Upon failure, the CRL will remain in the queue
for another attempt.

By default, the queue directory is in /var/spool/crlpublish.

=cut

sub processQueue() {

	loadConfiguration();

#	my $dir = $cfg->spooldirectory
#		or die "Asynchronous publishing is not configured.\n";

	# look through spooldirectory; push then remove

	return 0;
}


###############################################################################

=head1 AUTHOR

Kevin Cody-Little <kcody@cpan.org>

=cut


###############################################################################
####################################### EOF ###################################
###############################################################################
1;
