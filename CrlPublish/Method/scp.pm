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

use base 'EJBCA::CrlPublish::Method';

our $VERSION = 0.3;


sub validate {
	my $self = shift;

	$self->argMustExist( qw( crlFile remoteHost remotePath remoteFile ) );

}

sub publish {
	my $self = shift;

	my @args = ( 'scp' );

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

	my $target = '';
	$target .= $user . '@' if $user;
	$target .= $host . ':' . $path . '/' . $file;

	push @args, $source, $target;

	system( @args ) == 0
		or die "Failed to scp: $?";

	return 1;
}


###############################################################################
####################################### EOF ###################################
###############################################################################
1;
