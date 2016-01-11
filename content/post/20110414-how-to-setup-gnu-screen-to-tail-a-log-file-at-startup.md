+++
date = "2011-04-14"
title = "How to setup GNU screen to tail a log file at startup "
slug = "how-to-setup-gnu-screen-to-tail-a-log-file-at-startup"
aliases = [
    "/post/10163226008/how-to-setup-gnu-screen-to-tail-a-log-file-at"
]
+++

At work I used byobu on my Fedora machine as a wrapper around screen, and I’ve
setup my `.byobu/windows` file (which is a bit of a replacement for `.screenrc`
in a normal screen session) to open up all of the screen windows I like to have
at startup. 

I like to start a new session with a few dedicated windows setup:

1. A window titled "logs" which tails the log file of the main application I’m
   working on

2. A window titled "errors" which tails the same log file as #1, but piping the
   output to grep to watch for ERRORs

3. A window titled "project" which starts in my project’s main directory

4. A window titled "bash" which starts in my home directory.

My `.screenrc` (actually, `.byobu/windows`) looked like this:

```
# window 1
chdir /home/matt/code/project/logs
screen -t 'logs'

# window 2
chdir /home/matt/code/project/logs
screen -t 'errors'

# window 3
chdir /home/matt/code/project
screen -t 'project'

# window 4
chdir
screen -t 'bash'
```

To actually start the tail process, I used to always search through my command
history to find the correct tail command I wanted to use in the window (either
`tail -F current.log` or `tail -F current.log | grep -A 3 ERROR` to watch for
the ERRORS only).

**Until today, that is, when I figured out how to setup screen to run these
commands for me automatically when the screen session starts.**

There seems to be two ways to go about this:

1. You can simply include the command you want to run in this window in the
   line containing `screen -t`, such as

    ```
    screen -t 'logs' tail -F current.log
    ```
 
    however, this breaks if you want the command to include a pipe, such as 
 
    ```
    screen -t 'errors' tail -F current.log | grep -A 3 "ERROR"
    ```
     
    and I couldn’t figure out the correct way to escape this.

    Setting up the screen window this way will also cause screen to exit the
    window entirely if you enter `Ctrl+C`, rather than just exiting the command
    and returning you to the shell (which makes sense if you think about it).

2.  Another way to execute a command in the window at startup is to use the
    stuff command, which will paste whatever string you want into the input
    buffer of the current window. The trick here is to also include the escape
    sequence for the Enter key, to simulate someone actually entering the
    command and then pressing enter at the keyboard:

    ```
    screen -t 'errors'
    stuff 'tail -F /var/ec/current.log | grep -A 3 "ERROR"^M'
    ```

    (the `^M` is entered by pressing Ctrl+V, Enter with your keyboard, not by
    actually typing caret and uppercase M)

This works like a charm - when I start a new screen/byobu session, I have
windows named "logs" and "errors" setup which are already tailing the log files
I would like them to. 

Sources that were helpful in figuring out how to set this up:

* Stack Overflow question on ["how can I make vim send command to gnu screen session"][1]
* [Screen User Manual][2]
* [Screen FAQ][3]

[1]: http://stackoverflow.com/questions/1512915/how-can-i-make-vim-send-command-to-gnu-screen-session
[2]: http://www.gnu.org/software/screen/manual/screen.html
[3]: http://aperiodic.net/screen/faq#how_to_send_a_command_to_a_window_in_a_running_screen_session_from_the_commandline
