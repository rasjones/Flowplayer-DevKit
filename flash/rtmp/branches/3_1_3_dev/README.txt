Version history:

3.1.2
-----
- Starts RTMP and RTMPT connection attempts in parallel. The one who succeeds first will be used and the other one is discarded.
  The approach is described here: http://kb2.adobe.com/cps/185/tn_18537.html#http_improv
- New configuration option proxyType. Default value is "best". See http://livedocs.adobe.com/flash/9.0/ActionScriptLangRefV3/flash/net/NetConnection.html#proxyType

3.1.1
-----
- Possibility to query stream durations from the server. New config option 'durationFunc' for this.

3.1.0
------
- Subscribing connection establishment for Akamai and Limelight. Enabled by setting subscribe: true in the plugin config.
- Added objectEncoding config option, needed to connect to FMS2

3.0.2
-----
- the progress bar now moves to the latest seek position
- bufferbar now shows how much data has been buffered ahead of the current playhead position
- compatible with flowplayer 3.0.3 provider API
- made it possible to specify a full rtmp URL in clip's url. In this case the netConnectionUrl variable is not needed in the provider config.

3.0.1
-----
- dispatches the LOAD event when initialized (needed for flowplayer 3.0.2 compatibility)

3.0.0
---
- 3.0.0 final

beta3
-----
- compatibility with core rc4

beta1
-----
- First public beta release
