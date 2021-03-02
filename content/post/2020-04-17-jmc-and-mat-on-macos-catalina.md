---
title: "How to run Java Mission Control and Eclipse Memory Analyzer on MacOS Catalina"
date: 2020-04-17T10:17:54-04:00
slug: "how-to-run-jmc-and-eclipse-memory-analyzer-on-macos-catalina"
---

I am not sure if it is MacOS or the state of the Java development tool
ecosystem, but it seems to get harder and harder over time to use some common
tools.

I had to bang my head a bit to get both Eclipse Memory Analyzer and Java Mission
Control to actually run recently, so I wanted to write down the steps to easily
remember them in the future. Hopefully this helps someone else too.

## Eclipse Memory Analyzer

Downloading Eclipse Memory Analyzer from the official page gives you a `mat.app`
(after unzipping) which won't open on Catalina:

![Screenshot](/images/2020-04-17-mat-not-verified-error.png)

You have to remove the `com.apple.quarantine` attribute with:

```
xattr -r -d com.apple.quarantine ~/Downloads/mat.app/
```

After this when launching the app, you might get "Failed to create the Java
Virtual Machine":

![Screenshot](/images/2020-04-17-mat-jvm-error.png)

In Finder, right-click on mat.app and select Show Package contents, and edit the
`Contents/Eclipse/MemoryAnalyzer.ini` file. Add the path to your `java` binary
by adding

```
-vm
<path to java>
```

Each argument (`-vm`, and the path to `java`) have to be on their own line.

**It is important to note that this has to be at the start of the file**, adding
these options instead to the end of the file seems to cause them to be ignored.

This should allow you to launch the application, but you _may_ need to add an
additional argument to `Contents/Eclipse/MemoryAnalyzer.ini` to tell Eclipse
which workspace to use...

```
-data
<path to a directory to use as workspace>
```

... even though Eclipse Memory Analyzer doesn't seem to put any files there.

I didn't personally have this problem, but some questions on Stack Overflow
about running EMA on MacOS mention [needing to move the .app to the
`/Applications` directory][ema-so].

[ema-so]: https://stackoverflow.com/questions/47909239/how-to-run-eclipse-memory-analyzer-on-mac-os

## Java Mission Control

JMC is a mess since Java 8 and since Oracle open sourced it.

If you happen to visit https://openjdk.java.net/projects/jmc/, the project home
page tells you that version 7 is in development without any download link. You
have to know to visit https://jdk.java.net/jmc/ to actually find a download link
for version 7 (which is now generally available).

After downloading the .tar.gz and decompressing it, simply double-clicking on
the `JDK Mission Control.app` will give you the same

> “JDK Mission Control” can’t be opened because Apple cannot check it for malicious software.

error, although this time right-clicking on the app and selecting Open seems to
get pass the quarantine problem.

Next, you may get the same `Failed to create Java Virtual Machine` error from JMC:

![Screenshot](/images/2020-04-17-jmc-jvm-error.png)

The solution is to launch the `jmc` binary bundled in the .app package from the
command-line so you can pass a `-vm` flag to your `java` binary, for example:

```
~/Downloads/jmc-7.0.1+01_osx-x64_bin/JDK\ Mission\ Control.app/Contents/MacOS/jmc \
-vm /Library/Java/JavaVirtualMachines/amazon-corretto-11.jdk/Contents/Home/bin/java
```
