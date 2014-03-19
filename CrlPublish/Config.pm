package EJBCA::CrlPublish::Config;
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

our $VERSION = 0.3;

{ # private lexicals begin

my %CONFIG = ();

sub configValue {
	my ( $class, $section, $name, $value ) = @_;

	my $ref = $CONFIG{$section} ||= {};

	if ( defined $value ) {
		$ref->{$name} = $value;
	}

	return $ref->{$name};
}

sub applySection {
	my ( $class, $section, $target ) = @_;

	my $ref = $CONFIG{$section}
		or return;

	foreach my $name ( keys %$ref ) {
		my $value = $ref->{$name};
		$target->$name( $value );
	}

}

} # private lexicals end


###############################################################################
# Data Import Methods

sub importAllFiles {
	my ( $class, $path ) = @_;
	my $dh;

	return 1 unless -d $path;

	opendir $dh, $path
		or die "opendir($path): $!\n";

	while ( my $dirent = readdir $dh ) {
		next if $dirent =~ /^\./;

		my $ffmt = 'unknown';
		$ffmt = 'old' if $dirent =~ /\.conf$/;
		$ffmt = 'new' if $dirent =~ /\.cfg$/;

		my $file = $path . '/' . $dirent;
		my $fcfg = $class->parseFile( $file );

		if ( $ffmt eq 'old' ) {
			$class->importOldFile( $fcfg->{_} )
				or return undef;
		}

		elsif ( $ffmt eq 'new' ) {
			$class->importNewFile( $fcfg );
		}

		else {
			die "Unknown config file format";
		}

	}

	closedir $dh;

}

sub importOldFile {
	my ( $class, $fcfg ) = @_;

	my $sec;

	if    ( $sec = $fcfg->{section} ) {
		delete $fcfg->{section};
	}

	elsif ( $sec = $fcfg->{issuerDn} ) {
		delete $fcfg->{issuerDn};
	}

	else {
		die "Cannot determine config section!\n";
	}

	foreach my $name ( keys %$fcfg ) {
		$class->configValue( $sec, $name, $fcfg->{$name} );
	}

	return 1;
}

sub importNewFile {
	my ( $class, $fcfg ) = @_;

	foreach my $sec ( keys %{$fcfg} ) {
		foreach my $name ( keys %{$fcfg->{$sec}} ) {
			$class->configValue( $sec, $name,
						$fcfg->{$sec}->{$name} );
		}
	}

	return 1;
}

sub parseFile {
	my ( $class, $file ) = @_;

	open my $fh, '< ' . $file
		or die "open($file): $!\n";

	my %rv;
	my $sec = '_';

	while ( my $txt = <$fh> ) {
		chomp( $txt );
		$txt =~ s/#.*//;
		$txt =~ s/^\s+//;
		$txt =~ s/\s+$//;
		next unless $txt;

		if ( $txt =~ /^\s*\[.*\]\s*$/ ) {
			$txt =~ s/^\s*\[//;
			$txt =~ s/\]\s*$//;
			$sec = $txt;
			next;
		}

		my ( $var, $val ) = split /\s*=\s*/, $txt, 2;

		if ( $val =~ /^'/ ) {
			$val =~ s/^'//;
			$val =~ s/'$//;
		}

		elsif ( $val =~ /^"/ ) {
			$val =~ s/^"//;
			$val =~ s/"$//;
		}

		if ( $var eq 'remoteLocation' ) {
			my @part = split /\//, $val;
			my $file = pop @part;
			my $path = join ( '/', @part );
			$rv{$sec}->{remotePath} = $path;
			$rv{$sec}->{remoteFile} = $file;
		}

		elsif ( $var eq 'privateKey' ) {
			$rv{$sec}->{privateKeyFile} = $val;
		}

		else {
			$rv{$sec}->{$var} = $val;
		}

	}

	close( $fh );

	return \%rv;
}


###############################################################################
####################################### EOF ###################################
###############################################################################
1;