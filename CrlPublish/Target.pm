package EJBCA::CrlPublish::Target;
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
# Library dependencies.

use Carp;

our $VERSION = 0.3;


###############################################################################
# Instantiator for a single empty Target object.

sub new {
	my ( $class, %args ) = @_;

	$class = ref( $class ) if ref( $class );

	unless ( $class->isa( __PACKAGE__ ) ) {
		confess "Asinine construction of $class";
	}

	bless my $self = {}, $class;

	foreach my $arg ( keys %args ) {
		$self->$arg( $args{$arg} );
	}

	return $self;
}

sub copyObject {
	my $self = shift;

	my $obj = bless { %$self }, ref( $self );

	return $obj;
}


###############################################################################
# Wrapper for configuration resolver. Returns a list of Target objects.

sub find {
	my ( $class, $crlInfo ) = @_;

	my $issuerDn = $crlInfo->issuerDn;

	my $targ = $class->new(
			crlInfo  => $crlInfo,
			issuerDn => $issuerDn );
	
	# apply fixed defaults
	$targ->publishMethod( 'scp' );

	# apply crlInfo details
	if ( $crlInfo->issuingUrl ) {
		$targ->issuingUrl( $crlInfo->issuingUrl );
		$targ->remoteHost( $crlInfo->issuingHost );
		$targ->remotePath( $crlInfo->issuingPath );
		$targ->remoteFile( $crlInfo->issuingFile );
	}

	# apply defaults section
	EJBCA::CrlPublish::Config->applySection( 'defaults', $targ );

	# apply issuerDn specific section
	EJBCA::CrlPublish::Config->applySection( $issuerDn, $targ );

	# apply target host specific section
	EJBCA::CrlPublish::Config->applySection( $targ->remoteHost, $targ );

	my @targets;
	foreach my $remoteHost ( split /\s*,\s*/, $targ->remoteHost ) {
		my $target = $targ->copyObject;
		$target->remoteHost( $remoteHost );
		push @targets, $target;
	}

	return @targets;
}


###############################################################################
# Fixed attribute mutator methods

sub crlFile {
	my $self = shift;
	return undef unless $self->crlInfo;
	return $self->crlInfo->crlFile;
}


###############################################################################
# Automagic attribute mutator method generator

sub attrib {
	my ( $self, $name, $value ) = @_;

	if ( defined $value ) {
		$self->{$name} = $value;
	}

	return $self->{$name};
}

our $AUTOLOAD;

sub AUTOLOAD {
	my $this = shift;
	my $name = $AUTOLOAD;

	# only function for instance calls
	unless ( ref( $this ) and $this->isa( __PACKAGE__ ) ) {
		confess "Method $name not found";
	}

	# strip off the "fully qualified" part of the method name
	$name =~ s/.*://;

	# bail immediately if it's looking for a destructor
	return if $name eq 'DESTROY';

	my $func = sub {
		my $self = shift;
		return $self->attrib( $name, shift );
	};

	{
		no strict 'refs';
		*$AUTOLOAD = $func;
	}

	return &$func( $this, @_ );
}


###############################################################################
####################################### EOF ###################################
###############################################################################
1;
