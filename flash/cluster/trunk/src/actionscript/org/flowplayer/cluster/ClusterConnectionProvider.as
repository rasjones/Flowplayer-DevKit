/*     *    Copyright 2008 Anssi Piirainen * *    This file is part of FlowPlayer. * *    FlowPlayer is free software: you can redistribute it and/or modify *    it under the terms of the GNU General Public License as published by *    the Free Software Foundation, either version 3 of the License, or *    (at your option) any later version. * *    FlowPlayer is distributed in the hope that it will be useful, *    but WITHOUT ANY WARRANTY; without even the implied warranty of *    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the *    GNU General Public License for more details. * *    You should have received a copy of the GNU General Public License *    along with FlowPlayer.  If not, see <http://www.gnu.org/licenses/>. */package org.flowplayer.cluster {	import flash.events.Event;	import flash.events.IOErrorEvent;	import flash.events.NetStatusEvent;	import flash.net.NetConnection;	import flash.net.NetStream;		import org.flowplayer.cluster.event.RTMPEventType;	import org.flowplayer.controller.ConnectionProvider;	import org.flowplayer.controller.NetStreamControllingStreamProvider;	import org.flowplayer.controller.StreamProvider;	import org.flowplayer.controller.ClipURLResolver;	import org.flowplayer.model.Clip;	import org.flowplayer.model.ClipEvent;	import org.flowplayer.model.PluginModel;	import org.flowplayer.util.Log;	import org.flowplayer.util.PropertyBinder;	import org.flowplayer.util.URLUtil;	/**	 * A RTMP stream provider with fallback and clustering support. Supports following:	 * <ul>	 * <li>Starting in the middle of the clip's timeline using the clip.start property.</li>	 * <li>Stopping before the clip file ends using the clip.duration property.</li>	 * <li>Ability to combine a group of clips into one gapless stream.</li>	 * <li>Ability to fallback to a list of servers in a cluster server farm.</li>	 * <li>Ability to recognise, store and leave out any failed servers for a given time.</li>	 * <li>Ability to randomly connect to a server in the servers list mimicking a round robin connection.</li>	 * <li>Works with a traditional load balancing appliance by feeding its host at the top of the list, and direct connections to the servers happen on fallback.</li>	 * </ul>	 * <p>	 * Stream group is configured in a clip like this:	 * <code>	 * { streams: [ { url: 'metacafe', duration: 20 }, { url: 'honda_accord', start: 10, duration: 20 } ] }	 * </code>	 * The group is played back seamlessly as one gapless stream. The individual streams in a group can	 * be cut out from a larger file using the 'start' and 'duration' properties as shown in the example above.	 * 	 * <p> 	 * To enable server fallback a hosts config property is required in the plugins config like this:	 * 	 * hosts: [	 *	       'rtmp://server1.host.com/myapp',	 *	       'rtmp://server2.host.com/myapp',	 *	       'rtmp://server3.host.com/myapp',	 *	      ]	 * 	 * <p>	 * To enable the fallback feature to store (client side) failed servers to prevent reattempting those connections the failureExpiry config property is required like so:	 * failureExpiry: 3000,	 * 	 * <p> This tells the feature to wait for 3000 milliseconds before allowing connection attempts again. 	 * 	 * <p>	 * To enable round robin connections the loadBalanceServers config property requires to be enabled like so:	 * 	 * loadBalanceServers: true	 * 	 * <p>	 * Advanced configurations for the fallback feature can be enabled like so:	 * 	 * connectTimeout: 5000,	 * connectCount: 3	 * encoding: 0	 * 	 * <p> connectTimeout is the time in milliseconds before each reconnection attempt.	 * connectCount is the ammount of times connection reattmps will occur before giving up.	 * encoding is the AMF encoding version either 0 or 3 for AMF3.	 * 	 * <p> Two custom events a fired during connection attempts and fallback, these are:	 * 	 * <ul>	 * <li>RTMPEventType.RECONNECTED - onReconnect</li>	 * <li>RTMPEventType.FAILED - onFailed</li>	 * </ul>	 * 	 * @author danielr	 */	public class ClusterConnectionProvider implements ConnectionProvider, ClipURLResolver {		private var _config:ClusterConfig;		private var log:Log = new Log(this);		protected var _rtmpCluster:RTMPCluster;		private var _connection:NetConnection;		private var _netStream:NetStream;		private var _provider:StreamProvider;		private var _successListener:Function;		private var _failureListener:Function;		private var _connectionClient:Object;		private var _objectEncoding:uint;		private var _clip:Clip;		private var _rest:Array;		private var _httpClipURL:String;		private var _isComplete:Boolean = false;        public function onConfig(model:PluginModel):void {            log.debug("onConfig");             _config = new PropertyBinder(new ClusterConfig(), null).copyProperties(model.config) as ClusterConfig;             _rtmpCluster = new RTMPCluster(_config);			 _rtmpCluster.onFailed(onFailed);		 	 			             model.dispatchOnLoad();        }                public function getDefaultConfig():Object {        	return null;        }                        public function connect(provider:StreamProvider, clip:Clip, successListener:Function, objectEncoding:uint, ...rest):void {				_objectEncoding = objectEncoding;			_clip = clip;			_rest = rest;			_successListener = successListener;			_provider = provider as NetStreamControllingStreamProvider;			_connection = new NetConnection();			_connection.proxyType = "best";			_connection.objectEncoding = objectEncoding;						if (_connectionClient) {				_connection.client = _connectionClient;			}			_connection.addEventListener(NetStatusEvent.NET_STATUS, _onConnectionStatus);			_connection.addEventListener(IOErrorEvent.IO_ERROR, _netIOError);						var host:String = getNetConnectionUrl(clip);			if (rest.length > 0)			{				_connection.connect(host, rest);			} else if (_config.connectionArgs) {				_connection.connect(host, _config.connectionArgs);			} else {				_connection.connect(host);			}									if (isRtmpUrl(host)) {				_rtmpCluster.onReconnected(onRTMPReconnect);				_rtmpCluster.start();			}		}				private function _netIOError(event:IOErrorEvent):void 		{			log.error(event.text);		}        		protected function getNetConnectionUrl(clip:Clip):String {			var host:String = _rtmpCluster.host;						if (isRtmpUrl(host)) return host;						return null;		}				private function _onConnectionStatus(event:NetStatusEvent):void {			onConnectionStatus(event);			if (event.info.code == "NetConnection.Connect.Success" && _successListener != null) {				_rtmpCluster.stop();				_successListener(_connection);			} else if (["NetConnection.Connect.Failed", "NetConnection.Connect.Rejected", "NetConnection.Connect.AppShutdown", "NetConnection.Connect.InvalidApp"].indexOf(event.info.code) >= 0) {				log.error("Couldnt connect to " + _connection.uri);				if (_failureListener != null) {					_failureListener();				}			}			}				protected function onConnectionStatus(event:NetStatusEvent):void {		public function set connectionClient(client:Object):void {			if (_connection) {				_connection.client = client;			}			_connectionClient = client;		}				public function set onFailure(listener:Function):void {			_failureListener = listener;		}				protected function get connection():NetConnection {			return _connection;		}        public function handeNetStatusEvent(event:NetStatusEvent):Boolean {        	return true;        }        protected function get provider():StreamProvider {            return _provider;        }        protected function get failureListener():Function {            return _failureListener;        }        protected function get successListener():Function {            return _successListener;        }				/**		 * Fallback feature method called by the reconnection attempt timer		 */		protected function onRTMPReconnect(event:ClipEvent):void		{			//_connection.proxyType = "none";			_rtmpCluster.setFailedServer(_connection.uri);			_connection.close();			_rtmpCluster.stop();			connect(_provider, _clip, _successListener, _objectEncoding, _rest);			_clip.dispatchEvent(new ClipEvent(RTMPEventType.RECONNECTED));			log.info("Attempting reconnection");		}				protected function onHTTPReconnect(event:Event):void		{			_rtmpCluster.setFailedServer(_httpClipURL);			_rtmpCluster.stop();			resolveURL();			_clip.dispatchEvent(new ClipEvent(RTMPEventType.RECONNECTED));			log.info("Attempting reconnection");		}				protected function onFailed(event:ClipEvent):void		{			log.info("Connections failed");			_clip.dispatchEvent(new ClipEvent(RTMPEventType.FAILED));		}		protected function resolveURL():void		{			_httpClipURL = URLUtil.completeURL(_rtmpCluster.host, _clip.url);			log.debug("Attempting to resolve " + _httpClipURL);            _netStream.play(_httpClipURL);			_rtmpCluster.start();		}				private function _onNetStatus(event:NetStatusEvent):void {			if (event.info.code == "NetStream.Play.Start") {				clusterComplete();			}  else if (event.info.code == "NetStream.Play.StreamNotFound" || 				event.info.code == "NetConnection.Connect.Rejected" || 				event.info.code == "NetConnection.Connect.Failed") {					onHTTPReconnect(event);			}		}				protected function clusterComplete():void		{			log.debug("Resolved url " + _httpClipURL);			_isComplete = true;			_netStream.close();			_rtmpCluster.stop();			_clip.resolvedUrl = _httpClipURL;			_successListener(_clip);		}				public function resolve(provider:StreamProvider, clip:Clip, successListener:Function):void {            _clip = clip;            _successListener = successListener;            _provider = provider;            _provider.netStream.close();            _netStream = new NetStream(_provider.netConnection);            _netStream.addEventListener(NetStatusEvent.NET_STATUS, _onNetStatus);            _rtmpCluster.onReconnected(onHTTPReconnect);            _rtmpCluster.start();            resolveURL();        }				public static function isRtmpUrl(url:String):Boolean {			return url && url.toLowerCase().indexOf("rtmp") == 0;		}	}}