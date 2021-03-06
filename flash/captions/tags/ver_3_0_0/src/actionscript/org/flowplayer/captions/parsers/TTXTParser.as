/*
 * This file is part of Flowplayer, http://flowplayer.org
 *
 * By: Daniel Rossi, <electroteque@gmail.com>
 * Copyright (c) 2009 Electroteque Multimedia
 *
 * Released under the MIT License:
 * http://www.opensource.org/licenses/mit-license.php
 */
 
package org.flowplayer.captions.parsers
{
	import org.flowplayer.captions.NumberFormatter;
	import org.flowplayer.model.Cuepoint;
	import org.flowplayer.util.Log;
	import org.flowplayer.view.FlowStyleSheet;
	
	public class TTXTParser
	{
		private var tt:Namespace = new Namespace("http://www.w3.org/2006/10/ttaf1");
 		private var tts:Namespace = new Namespace("http://www.w3.org/2006/04/ttaf1#styling");
		private var ttm:Namespace =	new Namespace("http://www.w3.org/2006/10/ttaf1#metadata");	
		
		private var _styles:FlowStyleSheet;
		private var bodyStyle:String;
		private var _simpleFormatting:Boolean = false;
		private var cueRow:int = 0;
		internal static const SIMPLE_FORMATTING_PROPS:Array =  ["fontStyle", "fontWeight", "textAlign"];
		
		protected var log:Log = new Log(this);
		
		public function TTXTParser()
		{
			default xml namespace = tt;
		}
		
		public function get simpleFormatting():Boolean {
			return _simpleFormatting;
		}
		
		public function set simpleFormatting(simpleFormatting:Boolean):void {
			_simpleFormatting = simpleFormatting;
		}
		
		private function getStyleObj(style:String):Object
 		{
 			return _styles.getStyle("." + style);
 		}
 		
	      
	      public function parse(data:XML):Array
	      {
	      	parseStyles(data.head.styling.style);
	      	bodyStyle = data.body.hasOwnProperty("@style") ? data.body.@style : _styles.rootStyleName;
	      	return parseCaptions(data.body.div);
	      }
	      
	      public function get styles():FlowStyleSheet
	      {
	      	return _styles;
	      }
	      
	      public function set styles(style:FlowStyleSheet):void
	      {
	      	_styles = style;
	      }
	      
	      private function parseCaptions(div:XMLList):Array
	      {
	      	var arr:Array = new Array();
	      	var i:int = 0;
	      	
	      	for each (var property:XML in div)
 			{
 				var divStyle:String = property.hasOwnProperty("@style") ? property.@style : bodyStyle;
				var parent:XML = div.parent().parent();
	 			var lang:String = property.hasOwnProperty("@lang") ? property.@*::lang : parent.@*::lang;
	 			var begin:Number;
		 		var end:Number;
		
	 			if (property.hasOwnProperty("@begin"))
	 			{
	 				begin = NumberFormatter.seconds(property.@begin);
		 			end = property.hasOwnProperty("@dur") ?  NumberFormatter.seconds(property.@dur) : NumberFormatter.seconds(property.@end) - begin;
	 			}
	 	
	 			for each (var p:XML in property.p)
	 			{
	 				var time:int = begin ? begin : NumberFormatter.seconds(p.@begin);
	 				var cue:Object = Cuepoint.createDynamic(time, "embedded"); 
	 				var parameters:Object = new Object();
	 				var pStyle:String = getStyleObj(p.@style).hasOwnProperty("color") ? p.@style : divStyle;
	 				var endTime:int = end ? end : (p.hasOwnProperty("@dur") ? NumberFormatter.seconds(p.@dur) : NumberFormatter.seconds(p.@end) - time);
	 				var name:String = p.hasOwnProperty("@id") ? p.@*::id : (property.hasOwnProperty("@id") ? property.@*::id : "cue" + cueRow);
					
			        cue.captionType = "external";
	 				cue.time = time;
	 				cue.name = name;
	 				cue.type = "event";
	 				parameters.begin = time;
	 				parameters.end = endTime;
	 				parameters.lang = lang;
	 				parameters.style = pStyle;
	 				parameters.text = p.text();
	 				cue.parameters = parameters;
	 				arr.push(cue);
	 				cueRow++;
	 			}
		 		
 			}
 			
 			return arr;
	      }
	     
	      
	      public function parseStyles(style:XMLList):FlowStyleSheet
	      {
			
	      	for each (var styleProperty:XML in style)
	 		{
				var styleObj:Object = styleProperty.hasOwnProperty("@style") 
				? _styles.getStyle("." + styleProperty.@style)
				: {};
	
				for each (var attr:XML in styleProperty.@*)
				{
					var name:String = attr.name().localName;
					log.debug("style name " + name + ": " + SIMPLE_FORMATTING_PROPS.indexOf(name));
					if (! _simpleFormatting || SIMPLE_FORMATTING_PROPS.indexOf(name) >= 0) {
						log.debug("applied style " + name + " to value " + attr);
						styleObj[name] = attr;
					}
				}
				
				_styles.setStyle("." + styleProperty.@id, styleObj);
	 		}
	 		return _styles;
	      }

	}
}