+++
date = "2012-06-26"
title = "Graphing CPU temperature in OS X with Munin"
slug = "graphing-cpu-temperature-in-os-x-with-munin"
aliases = [
    "/post/25926855438/graphing-cpu-temperature-in-os-x-with-munin"
]
+++

Last week I made a plugin for [Munin][] to collect the temperature of my
Macbook’s CPU, hard drive, and GPU, for no real reason other than I thought it
would be need to see how they change over time, and because graphs are
irresistible.

![Screenshot](/images/20120626-screenshot.png)

The [plugin is on github][github-link]. It requires a free app called
[Temperature Monitor][] to be installed so the temperature values can be
collected in a script (I could not find any way built into OS X to collect the
data from the command-line, like you would read /proc on Linux).

[Munin]: http://munin-monitoring.org/
[github-link]: https://github.com/mattnworb/osx_munin_plugins
[Temperature Monitor]: http://www.bresink.de/osx/TemperatureMonitor.html
