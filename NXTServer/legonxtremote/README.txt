$Id: README.txt 2 2009-01-04 22:06:09Z querry43 $


LegoNXTRemote Software Distribution
-----------------------------------
This is a library for manipulating LEGO Mindstorms NXT bricks. It includes a
standalone Cocoa Framework and a sample Cocoa Remote application written in
Objective-C. It is multi-platform and is not dependent on LEGO libraries.

This project contains two products:

    LegoNXT.framework
        This is a framework providing the ability to manipulate a LEGO
        Mindstorms NXT brick over Bluetooth.  This framework exposes both
        low-level manipulations as well as a high-level interface for
        sensor polling.  This framework does not rely on the the LEGO
        fantomSDK or any other external libraries, making it easy to build
        and modify.

    LegoNXTRemote
        This is a sample application which makes use of the above framework
        to manipulate most functions of the LEGO Mindstorms NXT brick over
        Bluetooth.  It makes use of the native Bluetooth libraries for simple
        device discovery.


Use and Copyright
-----------------
This work is distributed unter the MIT/X11 license making it free for use,
modification, and distribution as described below.

Copyright (c) 2009 Matt Harrington

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
