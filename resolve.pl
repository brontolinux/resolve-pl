#!/usr/bin/perl

use strict ;
use warnings ;

use v5.10.1 ;

#use Socket qw(inet_ntop inet_pton AF_INET AF_INET6);
use Carp ;
use Socket qw(:DEFAULT :addrinfo IPPROTO_TCP inet_ntop inet_pton);
use Net::IP qw(ip_get_version);

my %address_type_cleartext ;
$address_type_cleartext{AF_INET()}  = "ipv4" ;
$address_type_cleartext{AF_INET6()} = "ipv6" ;


ENTRY:  foreach my $entry (@ARGV) {
    my $entry_type = ip_get_version($entry) ;

    if (not defined $entry_type) {
        # not an address, so probably a name?
        my ($err, @addrinfo) = getaddrinfo($entry, "", {protocol => IPPROTO_TCP, flags => AI_CANONNAME });
        if ($err) {
            report_error($entry,$err) ;
            next ENTRY ;
        }

        ADDRINFO:   foreach my $info (@addrinfo) {
            my ($error, $address) = getnameinfo($info->{addr}, NI_NUMERICHOST, NIx_NOSERV) ;
            
            if ($error) {
                report_error($entry,$error) ;
                next ADDRINFO ;
            }

            my %results ;
            $results{entry} = $entry ;
            $results{aliases} = $info->{canonname} if exists $info->{canonname} ;
            $results{addrs} = [ $address ] ;
            $results{addrtype} = $info->{family} ;
            report_results(%results) ;
        }

    }

    else {
        my ( $name,   $aliases,  $addrtype,  $length,  @addrs ) ;
        if ($entry_type == 4) {
            my $entry_address = inet_pton(AF_INET,$entry) ;
            ( $name,   $aliases,  $addrtype,  $length,  @addrs ) = gethostbyaddr($entry_address, AF_INET) ;
        }

        if ($entry_type == 6) {
            my $entry_address = inet_pton(AF_INET6,$entry) ;
            ( $name,   $aliases,  $addrtype,  $length,  @addrs ) = gethostbyaddr($entry_address, AF_INET6) ;
        }

        my %results ;
        $results{entry} = $entry ;
        $results{aliases} = $aliases if $aliases ;
        $results{addrs} = \@addrs ;
        $results{addrtype} = $addrtype ;
        report_results(%results) ;
    }

    
}

sub report_results {
    my %parms = @_ ;

    my $entry    = $parms{entry} ;
    my $aliases  = $parms{aliases} ;
    my @addrs    = @{ $parms{addrs} } ;
    my $addrtype = $parms{addrtype} ;

    if (defined $aliases and $entry ne $aliases) {
        say "$entry aliases $aliases" if defined $aliases ;
    }

    foreach my $address (@addrs) {
        say "$entry $address_type_cleartext{$addrtype} $address" ;
    }

}

sub report_error {
    my ($entry, $error) = @_ ;
    carp "While resolving $entry: error $error" ;
}