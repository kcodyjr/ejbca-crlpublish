package EJBCA::CrlPublish::Method::scp;
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

=head1 NAME

EJBCA::CrlPublish::Method::scp

=head1 SYNOPSIS

Implements publishing via scp.

Updates are atomic; that is, CRLs are transferred to a temporary file and
then renamed into place, so there is no period of time that an intact CRL
cannot be retrieved from the server.

=cut


###############################################################################
# Library Dependencies

use base 'EJBCA::CrlPublish::Method';

our $VERSION = 0.4;


###############################################################################
# Implementation

sub validate {
	my $self = shift;

	$self->argMustExist( qw( crlFile remoteHost remotePath remoteFile ) );

}

sub publish {
	my $self = shift;

	my @args = ();

	my $host = $self->target->remoteHost;
	my $path = $self->target->remotePath;
	my $file = $self->target->remoteFile;

	my $user = $self->target->remoteUser;
	my $pkey = $self->target->privateKeyFile;
	my $args = $self->target->scpExtraArgs;

	if ( $pkey ) {
		$self->checkFileType( 'SSH private key', $pkey );
		push @args, '-i', $pkey;
	}

	if ( $args ) {
		push @args, split /\s+/, $args;
	}

	my $source  = $self->target->crlFile;

	$self->checkFileType( 'CRL file', $source );

	my $t_host  = $user ? $user . '@' : '';
	   $t_host .= $host;
	my $t_file  = $path . '/' . $file;
	my $t_temp  = $t_file . '.new';

	my $target = $t_host . ':' . $t_temp;

	push @args, $source, $target;

	system( 'scp', @args, $source, $target ) == 0
		or die "Failed to scp: $?";

	system( 'ssh', @args, $t_host, 'mv', $t_temp, $t_file ) == 0
		or die "Failed to rename: $?";	

	return 1;
}


###############################################################################

=head1 AUTHOR

Kevin Cody-Little <kcody@cpan.org>

=cut


###############################################################################
####################################### EOF ###################################
###############################################################################
1;
