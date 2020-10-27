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

## Installation

### On UNIX-like systems

1. ensure you have the Net::IP module installed[*]
2. copy the script in a directory in your path; I suggest you rename it to `resolve`, e.g.: ```cp resolve.pl /usr/local/bin/resolve```
3. ensure the correct permissions for the script, e.g. ```chmod 755 /usr/local/bin/resolve```

[*] Net::IP is the only non-core module that is used by this script, and for only one thing: checking if the arguments passed on the command line are
IPv4/IPv6 addresses or not. There may be ways to do that and by using only core modules: you are welcome to submit a pull request, as I am not sure I
will have time in the future to invest into lightening this script.

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
