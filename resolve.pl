#!/usr/bin/perl

use strict ;
use warnings ;

use v5.10.1 ;

use Socket qw(inet_ntop inet_pton AF_INET AF_INET6);
use Net::IP qw(ip_get_version);

foreach my $entry (@ARGV) {
    my $entry_type = ip_get_version($entry) ;

    if (not defined $entry_type) {
        # not an address, so probably a name?
        my ( $name,   $aliases,  $addrtype,  $length,  @addrs ) = gethostbyname($entry) ;
        $name = "is undefined" if not defined $name ;
        say "$entry name $name" ;

        foreach my $packed_address (@addrs) {
            my $address = inet_ntop($addrtype, $packed_address) ;
            say "$entry address $address" ;
        }

        say "$name aliases $aliases" if $aliases ;
    }

    else {
        if ($entry_type == 4) {
            my $entry_address = inet_pton(AF_INET,$entry) ;
            my ( $name,   $aliases,  $addrtype,  $length,  @addrs ) = gethostbyaddr($entry_address, AF_INET) ;
            $name = "is undefined" if not defined $name ;
            say "$entry name $name" ;
            say "$name aliases $aliases" if $aliases ;
        }

        if ($entry_type == 6) {
            my $entry_address = inet_pton(AF_INET6,$entry) ;
            my ( $name,   $aliases,  $addrtype,  $length,  @addrs ) = gethostbyaddr($entry_address, AF_INET6) ;
            $name = "is undefined" if not defined $name ;
            say "$entry name $name" ;
            say "$name aliases $aliases" if $aliases ;
        }
    }
}