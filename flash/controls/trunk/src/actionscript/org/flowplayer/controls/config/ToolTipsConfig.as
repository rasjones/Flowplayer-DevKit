/*     *    Copyright 2008 Anssi Piirainen * *    This file is part of FlowPlayer. * *    FlowPlayer is free software: you can redistribute it and/or modify *    it under the terms of the GNU General Public License as published by *    the Free Software Foundation, either version 3 of the License, or *    (at your option) any later version. * *    FlowPlayer is distributed in the hope that it will be useful, *    but WITHOUT ANY WARRANTY; without even the implied warranty of *    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the *    GNU General Public License for more details. * *    You should have received a copy of the GNU General Public License *    along with FlowPlayer.  If not, see <http://www.gnu.org/licenses/>. */package org.flowplayer.controls.config {	import org.flowplayer.util.ObjectConverter;		import org.flowplayer.util.Log;			import org.flowplayer.controls.Controlbar;	import org.flowplayer.ui.controllers.AbstractWidgetController;	import org.flowplayer.ui.controllers.AbstractButtonController;		/**	 * @author api	 */		// This is really a consultation class	// no setters here	public dynamic class ToolTipsConfig extends AbstractWidgetsProps {		private var _marginBottom:Number = 5;				public function ToolTipsConfig(styleProps:Object, widgets:Array) {            super(styleProps is Boolean ? { scrubber: styleProps, volume: styleProps } : styleProps, widgets);			addWidgetsDefaults('tooltipLabel');			handleTooltipEnabled();		}		protected function handleTooltipEnabled():void {			for ( var i:int = 0; i < _availableWidgets.length; i++ ) {				var controller:AbstractWidgetController = _availableWidgets[i];				// buttons are global thanks to _props['buttons']				if ( !(controller is AbstractButtonController) && controller.defaults['tooltipEnabled'] != undefined ) {					addProperty(controller.name, controller.defaults['tooltipEnabled']);				}			}		}		[Value]		public function get buttons():Boolean {			return _props['buttons'] || false;		}				[Value]		public function get marginBottom():Number {			return _props['marginBottom'] || _marginBottom;		}			}}