# Tsinghua-Online

a chrome extension for TUNet (Tsinghua University Network) Client.

## Features
* staying in signed in automatically
* provide a real time Usage of Network traffic
* manage logged IP (view network traffic and logged out)

## Install (Chrome Plugin)
Use chrome store link: https://chrome.google.com/webstore/detail/tsinghua-online/elkbekfdkihpbcbacmppemegcekohkjo

If you can't open the link above for some reason, you can try this link: http://thudev.sinaapp.com/online

## Build
Tsinghua Online is built using [Grunt][]
```
npm install
grunt clean
grunt
```

Chrome plugin is in `build/` (unpacked)

Use `grunt dev` to watch changes in `src/`

[Grunt]: http://gruntjs.com/

## Revision History
** v1.0.0 **
* query real time Usage of Network traffic
* keep online automatically
* query the number of logged IP
* login / logout manually
* logout all IP

** v1.0.2 **
* installation check code

** v1.1.0 **
* manage IP
* FIX: display for real time Usage

** v1.2.0 **
* support new login page
* show device information in manage IP page
