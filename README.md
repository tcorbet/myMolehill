Description
===========
Sample code and documentation for use with Adobe Flash/AIR runtime support of GPU-accelerated graphics.

What's Here
===========

DC4 Project
-----------
All the source and most of the structure of a FlashDevelop project resulting in the DC4.swf file that you
will probably want to run through the standalone Flash Player or the plug-in provided by your favorite browser.
You are encouraged to download the sources, but probably you won't get a successful build because there are
probably some dependencies on my library of general-purpose ActionScript classes that will break the build.
If you find yourself in that state, just send me an email, and we'll try to find out what's missing, and fill
in the gaps.

DC6 AIR Apps
------------
One of the things you're going to discover is that maximum performance of this code cannot be obtained when
running in any of the Flash plug-ins currently used in any of the browsers. My own experience is that the
highest frame rate will be achieved in Chrome, with Firefox, Internet Explorer and Safari noticeably behind.
Your mileage, as they say, may differ, and that is particularly true since you probably have newer hardware and
software environmentts than I do. Since my work is all done on Windows XP, and since the browser folks have
pretty much left that ancient history behind, perhaps better browser performance will be observed on your systems.

In any case, the best container for the software is that provided by AIR, so you can grab one of the four
files that will let you see the demonstration running on your desktop. If you don't want to install the latest
version of AIR, use the files with the embedded runtime:  DC_Bundled.zip for Windows or DC_BundledApp.zip
for MacOS. If you do have the latest AIR on your system, just use DC6.exe or DC6.dmg as appropriate.

