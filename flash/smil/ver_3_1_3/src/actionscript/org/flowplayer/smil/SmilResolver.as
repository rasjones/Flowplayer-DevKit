/*
 * This file is part of Flowplayer, http://flowplayer.org
 *
 * By: Anssi Piirainen, Flowplayer Oy
 * Copyright (c) 2009 Flowplayer Oy
 *
 * Released under the MIT License:
 * http://www.opensource.org/licenses/mit-license.php
 */

package org.flowplayer.smil{
    import flash.events.NetStatusEvent;

    import org.flowplayer.controller.ClipURLResolver;
    import org.flowplayer.controller.ConnectionProvider;
    import org.flowplayer.controller.ResourceLoader;
    import org.flowplayer.controller.StreamProvider;
    import org.flowplayer.controller.StreamProvider;
    import org.flowplayer.model.Clip;
    import org.flowplayer.model.Clip;
    import org.flowplayer.model.Plugin;
    import org.flowplayer.model.PluginError;
    import org.flowplayer.model.PluginModel;
    import org.flowplayer.util.Log;
    import org.flowplayer.util.PropertyBinder;
    import org.flowplayer.view.Flowplayer;

    public class SmilResolver implements ClipURLResolver, Plugin {
        private var log:Log = new Log(this);
        private var _failureListener:Function;
        private var _player:Flowplayer;
        private var _model:PluginModel;
        private var _config:Config;
        private var _connectionClient:Object;
        private var _successListener:Function;
        private var _streamName:String;
        private var _objectEncoding:uint;
        private var _clip:Clip;
        private var _rtmpConnectionProvider:ConnectionProvider;

        public function resolve(provider:StreamProvider, clip:Clip, successListener:Function):void {
            log.debug("resolve(), resolving " + clip.url);
            _successListener = successListener;
            _clip = clip;

            loadSmil(_clip.url, onSmilLoaded);
        }

        [External]
        public function resolveSmil(smilUrl:String, callback:Function):void {
            log.debug("resolveSmil()");
            loadSmil(smilUrl, function(smilContent:String):void {
                var result:Array = parseSmil(smilContent);
                log.debug("resolveSmil(), resolved to netConnectionUrl " + result[0] + " streamName " + result[1]);
                callback(result[0], result[1]);
            });
        }

        private function loadSmil(smilUrl:String, loadedCallback:Function):void {
            log.debug("connect(), loading SMIL file from " + smilUrl);
            var loader:ResourceLoader = _player.createLoader();
            loader.load(smilUrl, function(loader:ResourceLoader):void {
                log.debug("SMIL file received");
                loadedCallback(String(loader.getContent()));
            }, true);
        }

        private function onSmilLoaded(smilContent:String):void {
            updateClip(_clip, smilContent);
            _successListener(_clip);
        }


        public function set onFailure(listener:Function):void {
            _failureListener = listener;
        }

        public function handeNetStatusEvent(event:NetStatusEvent):Boolean {
            return true;
        }

         public function set connectionClient(client:Object):void {
             _connectionClient = client;
         }

        public function onConfig(model:PluginModel):void {
            _model = model;
            _config = new PropertyBinder(new Config()).copyProperties(_model.config) as Config;

        }

        public function onLoad(player:Flowplayer):void {
            log.debug("onLoad");
            _player = player;
            _model.dispatchOnLoad();
        }

        public function getDefaultConfig():Object {
            return null;
        }

        private function updateClip(clip:Clip, smilFile:String):void {
            var result:Array = parseSmil(smilFile);
            log.debug("updateClip() baseUrl")
            clip.setCustomProperty("netConnectionUrl", result[0]);
            clip.baseUrl = null;
            clip.setResolvedUrl(this, result[1]);
        }

        private function parseSmil(smilFile:String):Array {
            log.debug("parsing SMIL file " + smilFile);
            var smil:XML = new XML(smilFile);
            return [smil.children()[0].children()[0].@base.toString(), smil.children()[1].children()[0].@src.toString()];
        }

    }
}