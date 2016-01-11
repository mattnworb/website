+++
date = "2011-09-13"
title = "Setting up a SSH tunnel to forward ports using Fedora 14"
slug = "setting-up-a-ssh-tunnel-to-forward-ports-using-fedora-14"
aliases = [
    "/post/10163228081/setting-up-a-ssh-tunnel-to-forward-ports-using"
]
+++

**TLDR: By default SELinux in Fedora 14 blocks sshd from forwarding traffic,
even if your `sshd_config` allows it. Run `setsebool -P sshd_forward_ports 1`
to allow forwarding.**

When working from home, I was attempting to set up a SSH tunnel to forward
traffic from my Macbook Pro to a Fedora machine I have on the network in the
office. We have a VPN to connect to in order to access machines on the
corporate network, but a particular internal web application has always been
very tricky to connect to over the VPN (for some unknown reason - it takes
minutes for any page to load).

After getting fed up with using VNC over the VPN to access this webapp from a
machine on the network - which is unbearably slow - I remembered I could try to
set up a ssh tunnel between my laptop and another machine I own on the network
(in a bit of an "aha, why didn’t I think of this 6 months ago!" moment).

Setting up the tunnel is simple: run this ssh command in a terminal window:

```
$ ssh -ND 5555 matt@officelinuxmachine
```

and then configure a browser to use 127.0.0.1 and port 5555 as a Socks v5
proxy.

However then I ran into something tricky - when I tried to access the
troublesome web app in the browser through the proxy, officelinuxmachine was
refusing my requests:

```
debug1: channel 2: new [dynamic-tcpip]
channel 2: open failed: administratively prohibited: open failed
debug1: channel 2: free: direct-tcpip: listening port 5555 for 10.22.15.138 port 80, connect from 127.0.0.1 port 62342, nchannels 3
```

(this is the output from the ssh client on my laptop, reporting that the other
side of the tunnel is prohibiting the open command)

After googling around a bit, I checked to make sure `/etc/ssh/sshd_config` on
the other side of the tunnel allowed tunneling (`AllowTcpForwarding yes`,
`PermitTunnel yes`) - which it did.

After a few minutes of frustration, I noticed this in `/var/log/messages` of
*officelinuxmachine*:

> Sep 13 08:44:33 officelinuxmachine setroubleshoot: SELinux is preventing
> /usr/sbin/sshd from name_connect access on the tcp_socket port 80. For
> complete SELinux messages. run sealert -l
> 4153f994-92e9-4d14-89e8-881c0c8d9669

Uh-oh, SELinux is blocking sshd from connecting, even though sshd itself is
configured ok! Running the `sealert` command to view the full alert yields this
output:

> SELinux is preventing /usr/sbin/sshd from name_connect access on the tcp_socket port 80.
>
> *****  Plugin catchall_boolean (47.5 confidence) suggests  *******************
>
> If you want to allow sshd to forward port connections then you must tell
> SELinux about this by enabling the 'sshd_forward_ports' boolean.

> Do setsebool -P sshd_forward_ports 1

Now it all makes sense - SELinux is set up to block sshd from forwarding ports by default. Executing

```
$ setsebool -P sshd_forward_ports 1
```

then allows the port to be forwarded as intended.
