Version history:

3.2.3
-----
- Fixed: the system-bitrate value in a SMIL file is specified in bps not in kbps
- Fixed: refactor normal to sd to suit changes with bwcheck , issue #240
- New Feature: Cluster server configuration support using a paramGroup tag. To be used in conjunction with the cluster and bwcheck plugin. #255
- Refactored resolveSmil api method to provide an object of type SmilItem for the callback argument. #255

3.2.2
-----
- Fixed parser to accomodate for optional bitrate properties required for the bwcheck hd button.

3.2.1
-----
 - Added bandwidth management: http://code.google.com/p/flowplayer-core/issues/detail?id=117&can=1&q=smil

3.1.3
-----
- refactored to be a ClipURLResolver

3.1.2
-----
- changes needed to support bandwidth checking

3.1.0
------
- first public release
