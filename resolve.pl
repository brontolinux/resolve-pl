#!/usr/bin/perl

use strict ;
use warnings ;

use v5.10.1 ;

use Socket qw(:DEFAULT :addrinfo IPPROTO_TCP inet_pton);

my %addrtype_text ;
$addrtype_text{AF_INET()}  = "ipv4" ;
$addrtype_text{AF_INET6()} = "ipv6" ;

ENTRY:  foreach my $entry (@ARGV) {
    if (_is_ip_address($entry)) {
        # IP address, can be v4 or v6, we don't care.
        my %results ;
        $results{entry} = $entry ;

        my ($err, @addrinfo) = getaddrinfo($entry,"", { protocol => IPPROTO_TCP, flags => AI_NUMERICHOST }) ;
        if ($err) {
            $results{error}  = $err ;
            report_results(%results) ;
            next ENTRY ;
        }

        ADDRINFO:   foreach my $info (@addrinfo) {
            my ($err, $hostname, $servicename) = getnameinfo($info->{addr},, NIx_NOSERV);

            if ($err) {
                $results{error}  = $err ;
                report_results(%results) ;
                next ADDRINFO ;
            }

            $results{name}     = $hostname eq $entry? "UNDEFINED": $hostname ;
            report_results(%results) ;
        }
    }


    else {
        # not an address, so probably a name?
        my %results ;
        $results{entry} = $entry ;

        my ($err, @addrinfo) = getaddrinfo($entry, "", {protocol => IPPROTO_TCP, flags => AI_CANONNAME });
        if ($err) {
            $results{error} = $err ;
            report_results(%results) ;
            next ENTRY ;
        }

        ADDRINFO:   foreach my $info (@addrinfo) {
            my ($error, $address) = getnameinfo($info->{addr}, NI_NUMERICHOST, NIx_NOSERV) ;
            
            if ($error) {
                $results{error} = $error ;
                report_results(%results) ;
                next ADDRINFO ;
            }

            $results{aliases}  = $info->{canonname} if exists $info->{canonname} ;
            $results{addrs}    = $address ;
            $results{addrtype} = $info->{family} ;
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
    my $error    = $parms{error} ;

    say "$entry error $error"                       if defined $error ;
    say "$entry alias $aliases"                     if defined $aliases and $entry ne $aliases ;
    say "$entry name $name"                         if defined $name ;
    say "$entry $addrtype_text{$addrtype} $address" if defined $address ;
}

sub _is_ip_address {
    my $is_address = inet_pton(AF_INET,$_[0]) or inet_pton(AF_INET6,$_[0]) ;
}