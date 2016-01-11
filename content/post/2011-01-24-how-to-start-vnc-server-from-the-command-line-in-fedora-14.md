+++
date = "2011-01-24"
title = "How to start VNC server from the command-line in Fedora 14"
slug = "how-to-start-vnc-server-from-the-command-line-in-fedora-14"
aliases = [
    "/post/10163223816/how-to-start-vnc-server-from-the-command-line"
]
+++

I’ve recently started using Linux (Fedora 14 to be specific) as my primary
development OS at work. I actually have two desktop machines side-by-side at my
desk - a Windows 7 PC for general office-type work and the Fedora machine for
development. When working from home, I have to remote into the Windows machine
and then use VNC from that machine to the Linux machine. The built-in VNC
server in Fedora (vino-server) is configured by default to start only once you
start a physically-logged-in session (since it runs as your local user, with
preference you set, etc).

This is fine most of the time, but when working from home I have a nasty habit
of forgetting how the setup I’m using actually works and logging out of my
physical session, thus terminating my VNC session and (GUI) access to the Linux
desktop machine. To get back in, I need to find someone in the office who can
walk over to my Linux desktop and log me in again. This is obviously a bit
annoying.

After a fair amount of searching of how vino-server could be restarted remotely
from the command line, I’ve found two methods for resolving this issue
(ironically most of the advice was from threads on the Ubuntu forums, notsomuch
on Fedora sites). The first option is rather ugly in that it leaves your system
with a user who will be automatically logged in, and stored passwords will be
saved to disk in plaintext. I would not suggest this approach unless absolutely
desparate:

### Solution 1: Set Gnome Desktop Manager to auto-login your user

One fix I found for this is to [setup Gnome Desktop Manager to auto-login your
user when it starts][1] (at boot); this solves the VNC problem fine but it
causes a few other problems of it’s own (listed below):

1. Edit /etc/gdm/custom.conf and add the two settings under the `[daemon]`
   section, each on their own line: `AutomaticLoginEnable=true` and
   `AutomaticLogin=yourUsername`. Now the next time that the machine boots,
   yourUsername will be logged in.

2. However, [Gnome has a feature][2] (the "keyring") in which it asks you to enter a
   master password to unlock the keyring, in which Gnome and other applications
   in your system can store any password information you save in an encrypted
   manner. If GDM auto-logs in your user, Gnome will be sitting at a screen
   where it is asking the user *at the physical display* to enter the master
   password to unlock the keyring. If you are remote at this time, you will not
   be able to enter in the password! To prevent this behavior, rename or delete
   the `~/.gnome2/keyrings/login.keyring` file.

3. A new keyring needs to be created to replace the previous - to do so you can
   either (from a physical login) attempt to store a new password, triggering
   Gnome to prompt you for a new keyring password (you must set the password as
   blank for this method to work), or create the file
   `~/.gnome2/keyrings/default` with the content of just the word `default` (no
   quotes).

4. From now on you should be able to VNC if you ever log out of your physical
   session, since Gnome will automatically log your user back in.

The **nasty side-effect** of this method is that with an empty keyring
password, **any stored passwords in your local account are stored on disk in
plaintext**. If you save a password to your IM account in Pidgin, or your email
account password in Thunderbird, etc., all of these are stored in
`~/.gnome2/keyrings/default.keyring` in plaintext.

This might not seem so bad at first glance since this file is readable by only
your user, until you remember that your account will automatically be logged in
whenever the machine boots. All someone needs to do is reboot your machine -
even if you have locked the display - to gain access to your files.

As mentioned above, this solution is not that great due to the side-effects - I
would really not recommend doing this unless nothing else works.    

### Solution 2: Start vino-server over X11 Forwarding

It is possible to start a new vino-server instance if you login to the target
machine with X11 forwarding.

First, ssh to the target machine with `ssh -X targetmachine` (note, if you get
warning messages about `untrusted X11 forwarding setup failed`, [try `ssh -Y`
instead][3]).

If you are using Windows on the machine you are doing this from, you can
install Cygwin and the X11 options (in Cygwin’s installer, select “xorg-server”
from the X11 category, this should pull in a lot of other dependencies
automatically). Once installed, open a Cygwin terminal and run `startx`. Then
start the ssh session using the terminal windows within the X windows that have
popped up on the Windows machine.

Once logged into the target machine, switch to the root account (using `sudo
-s`) and then run `DISPLAY=:0.0 xhost +` to allow remote access to the local X
server.  Then exit from root, and as your normal user run `DISPLAY=:0.0
/usr/libexec/vino-server` to start a new instance of vino-server.

It’s necessary to prepend these commands with `DISPLAY=:0.0` to have them use
the X display of the physical display.

To recap:

1. `ssh -X targetmachine`

2. `sudo -s` to change to root

3. Run `DISPLAY=:0.0 xhost +`

4. exit from root

5. Run `DISPLAY=:0.0 /usr/libexec/vino-server` as the regular user to start
   vino-server again

6. You should now be able to connect via SSH and start a new login session as
   if you were sitting at the machine.

Note that from here, if you terminate the SSH session in which you spawned
vino-server, then the VNC server will be shut down as well. To re-start the VNC
server, you can either re-do these steps or (if connected to the target machine
via VNC) open `vino-preferences` (either by running the command or navigating
to `System > Preferences > Remote Access`). Simply running `vino-preferences`
seems to start a new instance of vino-server if none is already running.

[This thread on the Ubuntu forums][4] was a big help in figuring out how to get
this to work.

Compared to Solution 1, this solution does not leave your machine in a state in
which it could be comprimised - no automatic login or keyring password options
need to be changed.

[1]: http://www.fedoraforum.org/forum/showthread.php?t=236860
[2]: https://webstats.gnome.org/GnomeKeyring
[3]: http://dailypackage.fedorabook.com/index.php?/archives/48-Wednesday-Why-Trusted-and-Untrusted-X11-Forwarding-with-SSH.html
[4]: http://ubuntuforums.org/showthread.php?p=10393025#post10393025
