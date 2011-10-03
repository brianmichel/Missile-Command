Missile Command
================

A basic control app for the Dream Cheeky Thunder USB Missile Launcher.

Things You Should Know
----------------------

 As of writing this (09/27/2011), there are two branches for this project. The master branch contains code that was written for an ARC enabled compiler. The no_arc branch contains code that should work just fine with a non-ARC enabled compiler.

 I've only tested this with the Dream Cheeky Thunder USB Missile Launcher, but it may work with the Dream Cheeky O.I.C. missile launcher as well. Feel free to give it a try and let me know!

**Important:** The no_arc branch will not be updates as frequently as the master branch is updated. I will try to do my best, but I know it will end up lagging behind at some point.

How To Use The App
------------------
 Click the ugly buttons on the window! 
 
 The app supports the following keyboard shortcuts:

 * `w` or `↑` - turret up
 * `a` or `←` - turret left
 * `s` or `↓` - turret down
 * `d` or `→` - turret right
 * `p` - turret stop
 * `space` - fire

It should be noted that the keyUp events on the window will trigger as turret stop event as well as a mouseUp action. This is so you can have somewhat fine grained control over the movement of the turret.

The Future
----------

 I'm working on making the desktop app advertise a Bonjour service so that the accompanying iPhone app (which I'm also working out right now), can find turrets available on a given network and gain control over them. 

Issues
-------

 The iPhone app is still only kind of working, you can send a couple of commands, but then the socket seems to just die. There are some issues with getting the socket again, but that will be addressed a little later.

Special Thanks
---------------

 Thanks to [codedance]("https://github.com/codedance") for the awesome retaliation python script, available [here]("https://github.com/codedance/Retaliation").
 
 Additionally, thanks to everyone who has contributed to the CocoaAsyncSocket project, available [here]("http://code.google.com/p/cocoaasyncsocket/").
