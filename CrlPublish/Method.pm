package EJBCA::CrlPublish::Method;
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
# Library dependencies

use Carp;

our $VERSION = 0.3;


###############################################################################
# Call the publisher on a target.. Only this should be called outside here.

sub execute {
	my ( $class, $target ) = @_;

	$class = ref( $class ) if ref( $class );

	unless ( $class->isa( __PACKAGE__ ) ) {
		confess "Asinine construction of $class";
	}

	unless ( $target->isa( 'EJBCA::CrlPublish::Target' ) ) {
		confess 'Expecting Target object, got ' . ref( $target );
	}

	my $meth = $target->publishMethod
		or confess "Unable to determine publishing method";

	my $oclass = __PACKAGE__ . '::' . $meth;
	my $classp = __PACKAGE__ . '::' . $meth . '.pm';
	$classp =~ s/::/\//g;

	require $classp or croak "Publishing method $meth not found";

	bless my $self = {}, $oclass;

	$self->{target}  = $target;

	return undef unless $self->validate;

	return $self->publish;
}


###############################################################################
# Return the target object that was passed to execute().

sub target {
	return (shift)->{target};
}


###############################################################################
# Helper functions for publishMethod implementations.

sub argMustExist {
	my $self = shift;

	while ( my $arg = shift ) {
		next if $self->target->$arg;
		croak "required argument $arg not present in target";
	}

	return 1;
}

sub checkFileType {
	my ( $self, $name, $path ) = @_;

	die "$name file '$path' not found.\n"
		unless -e $path;

	die "$name file '$path' not a file.\n"
		unless -f $path;

	die "$name file '$path' not readable.\n"
		unless -r $path;

	return 1;
}


###############################################################################
# Abstract class definitions. publishMethod subclasses must override these.

sub validate {
	my $self = shift;

	confess "Abstract method invocation";

}

sub publish {
	my $self = shift;

	confess "Abstract method invocation";

}


###############################################################################
####################################### EOF ###################################
###############################################################################
1;
