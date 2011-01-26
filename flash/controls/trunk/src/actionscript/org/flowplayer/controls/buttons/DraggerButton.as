 /* * This file is part of Flowplayer, http://flowplayer.org * *Copyright (c) 2008, 2009 Flowplayer Oy * * Released under the MIT License: * http://www.opensource.org/licenses/mit-license.php */package org.flowplayer.controls.buttons {    import flash.display.DisplayObject;	import flash.display.DisplayObjectContainer;    import flash.display.Sprite;	import org.flowplayer.controls.config.Config;    import org.flowplayer.view.AnimationEngine;		import org.flowplayer.ui.buttons.GenericTooltipButton;	import org.flowplayer.ui.buttons.TooltipButtonConfig;	import org.flowplayer.controls.SkinClasses;		/**	 * @author api	 */	public class DraggerButton extends GenericTooltipButton {		public function DraggerButton(config:TooltipButtonConfig, animationEngine:AnimationEngine) {					super("dragger", SkinClasses.getDisplayObject("fp.Dragger"), config, animationEngine);		}        override protected function get tooltipEnabled():Boolean {            return false;        }	}}