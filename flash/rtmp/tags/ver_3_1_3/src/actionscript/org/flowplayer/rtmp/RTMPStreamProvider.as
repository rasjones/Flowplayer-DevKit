/* * This file is part of Flowplayer, http://flowplayer.org * * By: Anssi Piirainen, <support@flowplayer.org> * Copyright (c) 2008 Flowplayer Ltd * * Released under the MIT License: * http://www.opensource.org/licenses/mit-license.php */package org.flowplayer.rtmp {	import org.flowplayer.controller.ClipURLResolver;	import org.flowplayer.controller.ConnectionProvider;	import org.flowplayer.controller.NetStreamControllingStreamProvider;	import org.flowplayer.model.Clip;	import org.flowplayer.model.ClipEvent;	import org.flowplayer.model.Plugin;	import org.flowplayer.model.PluginModel;    import org.flowplayer.util.PropertyBinder;    import org.flowplayer.util.URLUtil;    import org.flowplayer.view.Flowplayer;    import org.flowplayer.model.PluginEventType;		import flash.net.NetStream;		/**	 * A RTMP stream provider. Supports following:	 * <ul>	 * <li>Starting in the middle of the clip's timeline using the clip.start property.</li>	 * <li>Stopping before the clip file ends using the clip.duration property.</li>	 * <li>Ability to combine a group of clips into one gapless stream.</li>	 * </ul>	 * <p>	 * Stream group is configured in a clip like this:	 * <code>	 * { streams: [ { url: 'metacafe', duration: 20 }, { url: 'honda_accord', start: 10, duration: 20 } ] }	 * </code>	 * The group is played back seamlessly as one gapless stream. The individual streams in a group can	 * be cut out from a larger file using the 'start' and 'duration' properties as shown in the example above.	 * 	 * @author api	 */	public class RTMPStreamProvider extends NetStreamControllingStreamProvider implements Plugin {		private var _config:Config;		private var _model:PluginModel;		private var _bufferStart:Number = 0;        private var _player:Flowplayer;        private var _rtmpConnectionProvider:ConnectionProvider;        private var _subscribingConnectionProvider:ConnectionProvider;        private var _durQueryingConnectionProvider:ConnectionProvider;		/**		 * Called by the player to set my model object.		 */		override public function onConfig(model:PluginModel):void {            log.debug("onConfig()");			if (_model) return;			_model = model;			_config = new PropertyBinder(new Config(), null).copyProperties(model.config) as Config;		}		/**		 * Called by the player to set the Flowplayer API.		 */		override public function onLoad(player:Flowplayer):void {            _player = player;            if (_config.streamCallbacks) {                log.debug("configuration has " + _config.streamCallbacks + " stream callbacks");            } else {                log.debug("no stream callbacks in config");            }			_model.dispatchOnLoad();//			_model.dispatchError(PluginError.INIT_FAILED, "failed for no fucking reason");		}        override protected function getConnectionProvider(clip:Clip):ConnectionProvider {			if (clip.getCustomProperty("rtmpSubscribe") || _config.subscribe) {				log.debug("using FCSubscribe to connect");                if (! _subscribingConnectionProvider) {                    _subscribingConnectionProvider = new SubscribingRTMPConnectionProvider(_config);                }                return _subscribingConnectionProvider;			}            if (clip.getCustomProperty("rtmpDurationFunc") || _config.durationFunc) {                log.debug("using " + _config.durationFunc + " to fetch stream duration from the server");                if (! _durQueryingConnectionProvider) {                    _durQueryingConnectionProvider = new DurationQueryingRTMPConnectionProvider(_config, clip.getCustomProperty("rtmpDurationFunc") as String || _config.durationFunc);                }                return _durQueryingConnectionProvider;            }            log.debug("using the default connection provider");            if (! _rtmpConnectionProvider) {                _rtmpConnectionProvider = new RTMPConnectionProvider(_config);            }            return _rtmpConnectionProvider;		}		/**		 * Overridden to allow random seeking in the timeline.		 */		override public function get allowRandomSeek():Boolean {			return true;		}				/**         * Starts loading using the specified netStream and clip.         */        override protected function doLoad(event:ClipEvent, netStream:NetStream, clip:Clip):void {            if (hasStreamGroup(clip)) {                startStreamGroup(clip, netStream);            } else {                startStream(clip);            }        }				private function startStream(clip:Clip):void {            var streamName:String = getStreamName(clip);            log.info("starting playback of stream '" + streamName + "'");			if (clip.start > 0) {				netStream.play(streamName, clip.start, clip.duration > 0 ? clip.duration : -1);			} else {				netStream.play(streamName);			}		}        private function getStreamName(clip:Clip):String {            var url:String = clip.url;            if (URLUtil.isCompleteURLWithProtocol(clip.url)) {                var lastSlashPos:Number = url.lastIndexOf("/");                return url.substring(lastSlashPos + 1);            }            return url;        }				/**		 * Overridden to be able to store the latest seek target position.		 */		override protected function doSeek(event:ClipEvent, netStream:NetStream, seconds:Number):void {			_bufferStart = Math.floor(seconds);			super.doSeek(event, netStream, Math.floor(seconds));		}				override public function get bufferStart():Number {			if (! clip) return 0;			return _bufferStart;		}		override public function get bufferEnd():Number {			if (! netStream) return 0;			if (! clip) return 0;			return bufferStart + netStream.bufferLength;		}		/**		 * Starts streaming a stream group.		 */		protected function startStreamGroup(clip:Clip, netStream:NetStream):void {			var streams:Array = clip.customProperties.streams as Array;			log.debug("starting a group of " + streams.length + " streams");			var totalDuration:int = 0;			for (var i:Number = 0; i < streams.length; i++) {				var stream:Object = streams[i];				var duration:int = getDuration(stream);				var reset:Object = i == 0 ? 1 : 0; 				netStream.play(stream.url, getStart(stream), duration, reset);				if (duration > 0) {					totalDuration += duration;				}				log.debug("added " + stream.url + " to playlist, total duration " + totalDuration);			}			if (totalDuration > 0) {				clip.duration = totalDuration;			}		}		/**		 * Does the specified clip have a configured stream group?		 */		protected function hasStreamGroup(clip:Clip):Boolean {			return clip.customProperties && clip.customProperties.streams;		}		private function getDuration(stream:Object):int {			return stream.duration || -1;		}		private function getStart(stream:Object):int {			return stream.start || 0;		}				public function getDefaultConfig():Object {			return null;		}	}}