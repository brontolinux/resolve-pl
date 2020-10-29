# resolve - name/address resolution from the perspective of the OS

## What this is

It is a Perl script that does name and address resolution from the perspective of the Operating System. In other words,
it will resolve not only global DNS names, but also names propagated through multicast DNS and even names that are registered
only in your hosts file. It *may* do what you need, or not. Your mileage may vary. Use at your own risk.

It was supposed to be a very short program, a little exercise to build a tool that I need from time to time. Ideally, I should
have used only the `gethostby*` function calls and no external libraries at all.

Reality proved different. In particular, `gethostby*` functions work well enough with IPv4, but not as well for IPv6 (e.g.: if
you resolve a name, say `www.google.com` with `gethostbyname`). The solution involved using the `Socket` module's `getaddrinfo` and `getnameinfo`,
whose interface is more complex than the good old `gethostby*` functions. I reworked the script reluctantly, and finally I managed to make it work.

## Differences between `resolve` and `getent hosts`

As [Petru Ratiu told me on LinkedIn](https://www.linkedin.com/feed/update/urn:li:activity:6727162430654304256), this tool is basically replicating the functionality of the UNIX command `getent hosts`. That was not intended. In fact, and despite I've been using UNIX systems since at least 1995, I didn't know the command at all -- if I did, I probably had never created resolve. But since I did, here are the differences:

* The output of `getent hosts` mimics the format of `/etc/hosts`: first comes the address, then the hostname and aliases, if any; the output of `resolve` is: the queried entry first, then the type of response, then the response, e.g.:
```
$ resolve www.google.com
www.google.com ipv4 216.58.207.228
www.google.com ipv6 2a00:1450:400f:80d::2004
$ getent hosts www.google.com
2a00:1450:400f:80d::2004 www.google.com
$ 
```
Notice also how `getent hosts` only returned the IPv6 address.

* Unresolved entries are silently skipped by `getent hosts`, while `resolve` reports what's wrong with them, e.g.:
```
$ resolve www.rikstv.no foo.bar www.strim.no
www.rikstv.no alias commo-lbext-qh8b9sllo4hw-787619066.eu-west-1.elb.amazonaws.com
www.rikstv.no ipv4 54.228.16.94
www.rikstv.no ipv4 54.78.23.144
foo.bar error Name or service not known
www.strim.no ipv4 143.204.55.19
www.strim.no ipv4 143.204.55.72
www.strim.no ipv4 143.204.55.46
www.strim.no ipv4 143.204.55.126
$ getent hosts www.rikstv.no foo.bar www.strim.no
54.228.16.94    commo-lbext-qh8b9sllo4hw-787619066.eu-west-1.elb.amazonaws.com www.rikstv.no web-epi--ext-pm-aeuw1.rikstv.no
54.78.23.144    commo-lbext-qh8b9sllo4hw-787619066.eu-west-1.elb.amazonaws.com www.rikstv.no web-epi--ext-pm-aeuw1.rikstv.no
143.204.55.46   www.strim.no
143.204.55.72   www.strim.no
143.204.55.126  www.strim.no
143.204.55.19   www.strim.no
$ 
```

* The two tools use different system functions: where [`getent hosts` uses `gethostsbyaddr` and `gethostsbyname2`](https://manpages.debian.org/buster/manpages/getent.1.en.html), `resolve` uses `getaddrinfo` (which, by the way, is used by `getent ahosts`) and `getnameinfo`.

## Installation

This script uses only Perl Core modules, so all you need to use it is the **Perl interpreter** itself, **version 5.10.1 or above**. I don't think there are many places where versions lower than that are still in use, but in case you are using one of those versions and you still
want to use resolve, then just replace all `say "string"` in the code with `print "string\n"` and you are good to go.

### On UNIX-like systems

1. copy the script in a directory in your path; I suggest you rename it to `resolve`, e.g.: ```cp resolve.pl /usr/local/bin/resolve```
2. ensure the correct permissions for the script, e.g. ```chmod 755 /usr/local/bin/resolve```

### On other operating systems

No idea, pull requests welcome to patch this README with instructions.

## Usage

`resolve` will try to resolve all the names and addresses you put on the command line, for example:

```
$ resolve www.google.com 127.0.0.1 minardi.local raspberry-b.local 2a00:1450:400f:809::2004 arn11s02-in-x04.1e100.net ip6-localhost ip6-allnodes
www.google.com ipv4 172.217.22.164
www.google.com ipv6 2a00:1450:400f:806::2004
127.0.0.1 name localhost
minardi.local ipv4 192.168.100.20
raspberry-b.local ipv4 192.168.100.193
2a00:1450:400f:809::2004 name arn11s02-in-x04.1e100.net
arn11s02-in-x04.1e100.net ipv6 2a00:1450:400f:809::2004
ip6-localhost alias localhost
ip6-localhost ipv6 ::1
ip6-allnodes ipv6 ff02::1
$
```

Note how `resolve` resolved:
* names and addresses (both IPv4 and IPv6) from the DNS (e.g. www.google.com or 2a00:1450:400f:809::2004 )
* names from the hosts file (e.g. localhost, ip6-localhost)
* names from mDNS (e.g. `.local` domain names)

Reverse lookup of local names may work...

```
$ resolve 192.168.100.20
192.168.100.20 name minardi
$ resolve  192.168.100.1 
192.168.100.1 name _gateway
$ 
```

or not, depending on how the mapping is done and/or if there is a mapping at all:

```
$ resolve raspberry-b.local
raspberry-b.local ipv4 192.168.100.193
$ resolve 192.168.100.193  
192.168.100.193 name UNDEFINED
$ 
```

I repeat, YMMV.

# License

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <https://www.gnu.org/licenses/>.
