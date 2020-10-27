#!/usr/bin/perl

use strict ;
use warnings ;

use v5.10.1 ;

#use Socket qw(inet_ntop inet_pton AF_INET AF_INET6);
use Socket qw(:DEFAULT :addrinfo IPPROTO_TCP inet_ntop inet_pton);
use Net::IP qw(ip_get_version);

my %address_type_cleartext ;
$address_type_cleartext{AF_INET()}  = "ipv4" ;
$address_type_cleartext{AF_INET6()} = "ipv6" ;


ENTRY:  foreach my $entry (@ARGV) {
    my ( $name,   $aliases,  $addrtype,  $length,  @addrs ) ;
    my $entry_type = ip_get_version($entry) ;

    if (not defined $entry_type) {
        # not an address, so probably a name?
        my ($err, @addrinfo) = getaddrinfo($entry, "", {protocol => IPPROTO_TCP });
        if ($err) {
            report_error($entry,$err) ;
            next ENTRY ;
        }

        ADDRINFO:   foreach my $info (@addrinfo) {
            my %results ;
            $results{entry} = $entry ;
            $results{name} = $entry ;
            $results{aliases} = $info->{canonname} if exists $info->{canonname} ;
            $results{addrs} = [ $info->{addr} ] ;
            $results{addrtype} = $info->{family} ;
            report_results(%results) ;
            next ADDRINFO ;
            
            ##! remove later if not needed
            my ($err, $ipaddr) = getnameinfo($info->{addr}, NI_NUMERICHOST, NIx_NOSERV);
            if ($err) {
                report_error($entry,$err) ;
                next ENTRY ;
            }

        }
    }

    else {
        if ($entry_type == 4) {
            my $entry_address = inet_pton(AF_INET,$entry) ;
            ( $name,   $aliases,  $addrtype,  $length,  @addrs ) = gethostbyaddr($entry_address, AF_INET) ;
        }

        if ($entry_type == 6) {
            my $entry_address = inet_pton(AF_INET6,$entry) ;
            ( $name,   $aliases,  $addrtype,  $length,  @addrs ) = gethostbyaddr($entry_address, AF_INET6) ;
        }
    }

    
}

sub report_results {
    my %parms = @_ ;

    my $entry    = $parms{entry} ;
    my $name     = exists $parms{name} ? $parms{name} : "is undefined" ;
    my $aliases  = $parms{aliases} ;
    my @addrs    = @{ $parms{addrs} } ;
    my $addrtype = $parms{addrtype} ;

    say "$entry name $name" ;

    foreach my $packed_address (@addrs) {
        my ($error, $address) = getnameinfo($packed_address, NI_NUMERICHOST, NIx_NOSERV) ;
        if ($error) {
            report_error($parms{entry},$error) ;
            return ;
        }
        say "$entry $address_type_cleartext{$addrtype} $address" ;
    }

    say "$name aliases $aliases" if $aliases ;
}

sub report_error {
    my ($entry, $error) ;
    warn "While resolving $entry: error $error" ;
}