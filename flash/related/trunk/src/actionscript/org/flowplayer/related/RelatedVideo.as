/* * This file is part of Flowplayer, http://flowplayer.org * * By: Daniel Rossi, <electroteque@gmail.com> * Copyright (c) 2009 Electroteque Multimedia * * Released under the MIT License: * http://www.opensource.org/licenses/mit-license.php */package org.flowplayer.related {	import com.adobe.serialization.json.JSON;		import flash.display.DisplayObject;		import org.flowplayer.controller.ResourceLoader;	import org.flowplayer.controller.ResourceLoaderImpl;	import org.flowplayer.model.ClipEvent;	import org.flowplayer.model.DisplayProperties;	import org.flowplayer.model.PlayerError;	import org.flowplayer.model.Plugin;	import org.flowplayer.model.PluginEventType;	import org.flowplayer.model.PluginModel;	import org.flowplayer.util.PropertyBinder;	import org.flowplayer.view.ErrorHandler;	import org.flowplayer.view.Flowplayer;	import org.flowplayer.view.StyleableSprite;	import org.flowplayer.controller.ResourceLoader;	import org.flowplayer.model.PlayerError;		/**	 * A Subtitling and Captioning Plugin. Supports the following:	 * <ul>	 * <li>Loading subtitles from the Timed Text or Subrip format files.</li>	 * <li>Styling text from styles set in the Time Text format files.</li>	 * <li>Loading subtitles or cuepoints from a JSON config.</li>	 * <li>Loading subtitles or cuepoints from embedded FLV cuepoints.</li>	 * <li>Controls an external content plugin.</li>	 * <li>Working with the Javascript captions plugin, it enables a scrolling cuepoint thumbnail menu.</li>	 * </ul>	 * <p>	 * To setup an external subtitle caption file the config would look like so:	 * 	 * captionType: 'external'	 * 	 * For Timed Text	 *	 * captionUrl: 'timedtext.xml'	 * 	 * For Subrip	 * 	 * captionUrl: 'subrip.srt'	 * 	 * <p>	 * To enable the captioning to work properly a caption target must link to a content plugin like so:	 * 	 * captionTarget: 'content'	 * 	 * Where content is the config for a loaded content plugin.	 *	 * <p>	 * 	 * To be able to customised the subtitle text a template string is able to tell the captioning plugin	 * which text property is to be used for the subtitle text which is important for embedded cuepoints. It also	 * enables to add extra properties to the text like so:	 * 	 * template: '{text} {time} {custom}' 	 * 	 * <p>	 * To enable simple formatting of text if Timed Text has style settings, 	 * only "fontStyle", "fontWeight" and "textAlign" properties are able to be set like so:	 * 	 * simpleFormatting: true	 * 	 * @author danielr	 */	public class RelatedVideo extends StyleableSprite implements Plugin, ErrorHandler {				private var _player:Flowplayer;		private var _model:PluginModel;		private var _config:Config;		private var _relatedClips:Array;		private var oldDisplayProperties:DisplayProperties;		private var _isRelatedVideosOpen:Boolean = false;		private var coverFlow:CoverFlow;		private var _loader:ResourceLoader;		private var _currentIndex:Number = 0;		public function RelatedVideo() {					}				/**		 * Sets the plugin model. This gets called before the plugin		 * has been added to the display list and before the player is set.		 * @param plugin		 */		public function onConfig(plugin:PluginModel):void {			_model = plugin;			_config = new PropertyBinder(new Config(), null).copyProperties(plugin.config) as Config;			if (plugin.config) {			}		}								/**		 * Sets the Flowplayer interface. The interface is immediately ready to use, all		 * other plugins have been loaded an initialized also.		 * @param player		 */		public function onLoad(player:Flowplayer):void {			_player = player;			_player.playlist.onBeforeBegin(onBegin);			//_player.playlist.onBegin(onBegin);			_player.playlist.onBeforeFinish(onBeforeFinish);			_player.playlist.onFinish(onFinish);			//_player.playlist.onBegin(onBegin);			_loader = _player.createLoader();						coverFlow = new CoverFlow({			imageWidth: 150,			imageHeight: _config.thumbHeight,			horizontalSpacing: _config.horizontalSpacing,			relfectionSpacing: _config.relfectionSpacing,			showReflection: _config.showReflection			});						addChild(coverFlow);			_model.dispatchOnLoad();					}				private function isLastItem():Boolean		{			return _player.playlist.currentIndex + 1 >= _player.playlist.length;			}				private function onBeforeFinish(event:ClipEvent):void		{			//if (isLastItem()) event.preventDefault();		}				private function onFinish(event:ClipEvent):void		{			if (_config.showOnFinish && _relatedClips !=null)			{				if (_player.currentClip.autoPlay==false || isLastItem())				{					show();					//log.debug(_relatedClips.toString());				}			}		}					protected function onImageLoadComplete(loader:ResourceLoader):void		{			var image:DisplayObject = loader.getContent() as DisplayObject;						coverFlow.addImage(image);						_currentIndex++				if (_currentIndex < _relatedClips.length) {				loadRelatedClips();			} else {				coverFlow.startRendering();			}		}				protected function loadRelatedClips():void		{			var imageUrl:String = _relatedClips[_currentIndex].customProperties.thumbnail;						log.error("Loading image " + imageUrl);						_loader.load(imageUrl, onImageLoadComplete);		}				protected function getRelatedClips(related:*):void		{			if (related is Array)			{				log.debug("Loading related videos from config");				_relatedClips = _player.createClips(_player.currentClip.customProperties.related);				loadRelatedClips();			} else if (related is String) {				var loader:ResourceLoaderImpl = new ResourceLoaderImpl(null, this);				loader.load(related, onComplete, true);				log.debug("Loading related videos from external config " + related);			}		}				protected function onBegin(event:ClipEvent):void {			close();			if (_player.currentClip.customProperties.related != null)			{				getRelatedClips(_player.currentClip.customProperties.related);			} else if (_config.related != null) {				log.debug("Loading related clips from default config");				getRelatedClips(_config.related);			}						//log.error(_player.currentClip.customProperties.related);		}		public function getDefaultConfig():Object {			return {};		}				public function onComplete(loader:ResourceLoader):void		{			_relatedClips = _player.createClips(JSON.decode(loader.getContent().toString()));			loadRelatedClips();		}				public function showError(message:String):void		{			//log.error(message);		}				public function handleError(error:PlayerError, info:Object = null, throwError:Boolean = true):void		{			log.error(error.message);		}						[External]		public function open():void		{			if (!_isRelatedVideosOpen) show();		}				[External]		public function show():void		{			if (_relatedClips != null && _relatedClips.length > 0)			{				_model.dispatch(PluginEventType.PLUGIN_EVENT, "onBeforeShow");				var screen:DisplayProperties = _player.pluginRegistry.getPlugin("screen") as DisplayProperties;				oldDisplayProperties = screen;				_player.animationEngine.animate(screen.getDisplayObject(), _config.screen, 400, showRelatedVideos);			}		}				private function showRelatedVideos():void		{			_model.dispatch(PluginEventType.PLUGIN_EVENT, "onShow");			_isRelatedVideosOpen = true;						//coverFlow.shiftToItem(3);			log.error(_relatedClips.toString());		}				private function closeRelatedVideos():void		{			log.error("closed");			_model.dispatch(PluginEventType.PLUGIN_EVENT, "onClose");			_isRelatedVideosOpen = false;		}				[External]		public function close():void		{			if (_isRelatedVideosOpen) {				log.error("closing");				_model.dispatch(PluginEventType.PLUGIN_EVENT, "onBeforeClose");				_player.animationEngine.animate(oldDisplayProperties.getDisplayObject(), oldDisplayProperties, 400, closeRelatedVideos);			}		}				[External]		public function setItems(items:Array):void		{			_relatedClips = items;		}				[External]		public function click(index:int):void		{					}	}}