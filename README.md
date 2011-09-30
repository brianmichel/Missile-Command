Missile Command
================

A basic control app for the Dream Cheeky Thunder USB Missile Launcher.

Things You Should Know
----------------------

 As of writing this (09/27/2011), there are two branches for this project. The master branch contains code that was written for an ARC enabled compiler. The no_arc branch contains code that should work just fine with a non-ARC enabled compiler.

 I've only tested this with the Dream Cheeky Thunder USB Missile Launcher, but it may work with the Dream Cheeky O.I.C. missile launcher as well. Feel free to give it a try and let me know!

How To Use The App
------------------
 Click the ugly buttons on the window! 
 
 The app supports the following keyboard shortcuts:

 * `w` - turret up
 * `a` - turret left
 * `s` - turret down
 * `d` - turret right
 * `p` - turret stop
 * `space` - fire

It should be noted that the keyUp events on the window will trigger as turret stop event as well as a mouseUp action. This is so you can have somewhat fine grained control over the movement of the turret.

The Future
----------

 I'm working on making the desktop app advertise a Bonjour service so that the accompanying iPhone app (which I'm also working out right now), can find turrets available on a given network and gain control over them. 

Issues
-------

 The iPhone app is still only kind of working, can't seem to get the data to actually write to the socket and be received by the server. I'm not sure if the server is the issue, or if the socket is the issue. Working on it!

Special Thanks
---------------

 Thanks to [codedance]("https://github.com/codedance") for the awesome retaliation python script, available [here]("https://github.com/codedance/Retaliation").
 
 Additionally, thanks to everyone who has contributed to the CocoaAsyncSocket project, available [here]("http://code.google.com/p/cocoaasyncsocket/").
