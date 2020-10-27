#!/usr/bin/perl

use strict ;
use warnings ;

use v5.10.1 ;

use Carp ;
use Socket qw(:DEFAULT :addrinfo IPPROTO_TCP);
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
            $results{entry}    = $entry ;
            $results{aliases}  = $info->{canonname} if exists $info->{canonname} ;
            $results{addrs}    = $address ;
            $results{addrtype} = $info->{family} ;
            report_results(%results) ;
        }

    }

    else {
        # IP address, can be v4 or v6, we don't care.
        my ($err, @addrinfo) = getaddrinfo($entry,"", { protocol => IPPROTO_TCP, flags => AI_NUMERICHOST }) ;
        if ($err) {
            report_error($entry,$err) ;
            next ENTRY ;
        }

        ADDRINFO:   foreach my $info (@addrinfo) {
            my ($err, $hostname, $servicename) = getnameinfo($info->{addr},, NIx_NOSERV);

            if ($err) {
                report_error($entry,$err) ;
                next ADDRINFO ;
            }

            my %results ;
            $results{entry}    = $entry ;
            $results{name}     = $hostname ;
            report_results(%results) ;
        }
    }

    
}

sub report_results {
    my %parms = @_ ;

    my $entry    = $parms{entry} ;
    my $name     = $parms{name} ;
    my $aliases  = $parms{aliases} ;
    my $address  = $parms{addrs} ;
    my $addrtype = $parms{addrtype} ;

    if (defined $aliases and $entry ne $aliases) {
        say "$entry alias $aliases" if defined $aliases ;
    }

    if (defined $name) {
        say "$entry name $name" ;
    }

    if (defined $address) {
        say "$entry $address_type_cleartext{$addrtype} $address" ;
    }

}

sub report_error {
    my ($entry, $error) = @_ ;
    carp "While resolving $entry: error $error" ;
}