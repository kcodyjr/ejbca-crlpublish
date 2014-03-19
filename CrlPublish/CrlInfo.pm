package EJBCA::CrlPublish::CrlInfo;
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
# Constructor

our $VERSION = 0.3;

sub new {
	my ( $class, $crlFile ) = @_;

	bless my $self = {}, $class;

	$self->crlFile( $crlFile );
	return undef unless $self->importIssuerDn;
	$self->importIssuingUrl;

	return $self;
}


###############################################################################
# Data Import Methods

sub importIssuerDn {
	my ( $self ) = @_;
	my ( $f, $s );

	my $crlFile = $self->crlFile;

	$f = 'openssl crl -issuer -inform %s -noout -in "%s" 2>/dev/null';

	$s = sprintf $f, 'DER', $crlFile;
	return 1 if $self->tryImportIssuerDn( 'DER', $s );

	$s = sprintf $f, 'PEM', $crlFile;
	return 1 if $self->tryImportIssuerDn( 'PEM', $s );

	warn "Invalid CRL file '$crlFile'\n";

	return 0;
}

sub tryImportIssuerDn {
	my ( $self, $crlFormat, $string ) = @_;

	return 0 unless my $rawIssuer = `$string`;
	chomp $rawIssuer;

	$self->crlFormat( $crlFormat );

	$rawIssuer =~ s/^issuer=\///;
	$rawIssuer =~ s/\//,/g;

	$self->issuerDn( $rawIssuer );

	return 1;
}

sub importIssuingUrl {
	my ( $self ) = @_;

	my $s = 'openssl crl'
		. ' -in '     . $self->crlFile
		. ' -inform ' . $self->crlFormat
		. ' -noout -text'
		. ' 2> /dev/null';

	open my $fh, "$s |" or die $!;

	my $keepgoing = 1;
	while ( $keepgoing ) { 
		my $txt = <$fh>;

		unless ( defined $txt ) {
			$keepgoing = 0;
			next;
		}

		next unless $txt =~ "Issuing Distrubution Point:";

		$keepgoing = 0;
	}

	my $txt1 = <$fh>;
	return unless defined $txt1;
	chomp $txt1;
	$txt1 =~ s/^\s+//;
	$txt1 =~ s/\s+$//;
	unless ( $txt1 =~ /^Full Name:$/ ) {
		warn "CRL parse error: expected 'Full Name', got '$txt1'\n";
		return;
	}

	my $txt2 = <$fh>;
	return unless defined $txt2;
	chomp $txt2;
	$txt2 =~ s/^\s+//;
	$txt2 =~ s/\s+$//;
	unless ( $txt2 =~ /^URI:/ ) {
		warn "CRL parse error: expected 'URI', got '$txt2'\n";
		return;
	}

	my ( $dum0, $prot, $unc ) = split /:/, $txt2, 3;

	my ( $dum1, $dum2, $host, $path ) = split /\//, $unc, 4;

	my @part = split /\//, $path;
	my $file = pop @part;
	   $path = join( '/', @part );

	$self->issuingFile( $file );
	$self->issuingPath( $path );
	$self->issuingHost( $host );
	$self->issuingUrl( $prot . ';' . $unc );

	return 1;
}


###############################################################################
# Accessor Methods

sub crlFile {
	my ( $self, $crlFile ) = @_;

	if ( defined $crlFile ) {
		$self->{crlFile} = $crlFile;
	}

	return $self->{crlFile};
}

sub crlFormat {
	my ( $self, $crlFormat ) = @_;

	if ( defined $crlFormat ) {
		$self->{crlFormat} = $crlFormat;
	}

	return $self->{crlFormat};
}

sub issuerDn {
	my ( $self, $issuerDn ) = @_;

	if ( defined $issuerDn ) {
		$self->{issuerDn} = $issuerDn;
	}

	return $self->{issuerDn};
}

sub issuingFile {
	my ( $self, $issuingFile ) = @_;

	if ( defined $issuingFile ) {
		$self->{issuingFile} = $issuingFile;
	}

	return $self->{issuingFile};
}

sub issuingPath {
	my ( $self, $issuingPath ) = @_;

	if ( defined $issuingPath ) {
		$self->{issuingPath} = $issuingPath;
	}

	return $self->{issuingPath};
}

sub issuingHost {
	my ( $self, $issuingHost ) = @_;

	if ( defined $issuingHost ) {
		$self->{issuingHost} = $issuingHost;
	}

	return $self->{issuingHost};
}

sub issuingUrl {
	my ( $self, $issuingUrl ) = @_;

	if ( defined $issuingUrl ) {
		$self->{issuingUrl} = $issuingUrl;
	}

	return $self->{issuingUrl};
}


###############################################################################
####################################### EOF ###################################
###############################################################################
1;
