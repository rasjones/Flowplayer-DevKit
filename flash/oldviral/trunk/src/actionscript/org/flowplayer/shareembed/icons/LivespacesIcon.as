/*
 *    Author: Anssi Piirainen, <api@iki.fi>
 *
 *    Copyright (c) 2009 Flowplayer Oy
 *
 *    This file is part of Flowplayer.
 *
 *    Flowplayer is licensed under the GPL v3 license with an
 *    Additional Term, see http://flowplayer.org/license_gpl.html
 */
package org.flowplayer.shareembed.icons {
    import flash.display.DisplayObjectContainer;

    import org.flowplayer.ui.AbstractButton;
    import org.flowplayer.ui.ButtonConfig;
    import org.flowplayer.view.AnimationEngine;
    import org.flowplayer.viral.assets.LivespacesIcon;

    public class LivespacesIcon extends AbstractIcon {

        public function LivespacesIcon(config:ButtonConfig, animationEngine:AnimationEngine) {
            super(config, animationEngine, "Live Spaces");
        }

        override protected function createIcon():DisplayObjectContainer {
            return new org.flowplayer.viral.assets.LivespacesIcon();
        }
    }
}