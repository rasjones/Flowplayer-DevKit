/*
 * This file is part of Flowplayer, http://flowplayer.org
 *
 * By: Daniel Rossi, <electroteque@gmail.com>
 * Copyright (c) 2008 Electroteque Multimedia
 *
 * Released under the MIT License:
 * http://www.opensource.org/licenses/mit-license.php
 */
 
package org.flowplayer.bwcheck.servers
{

	import flash.net.Responder;
	
	import org.red5.flash.bwcheck.BandwidthDetection;
	
	public class FMSServerClientBandwidth extends BandwidthDetection
	{
		
		private var info:Object = new Object();
		private var res:Responder;
		
		public function FMSServerClientBandwidth()
		{

		}

		public function onBWCheck(... rest):Number
		{
				dispatchStatus(rest);
				return 0;
		}
			
		public function onBWDone(... rest):void 
		{ 
			var obj:Object = new Object();
			obj.kbitDown = rest[0];
			dispatchComplete(obj);
		} 
		
		
		override public function start():void
		{
			nc.client = this;
		}
	}
}