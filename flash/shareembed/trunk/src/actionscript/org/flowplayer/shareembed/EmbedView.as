/*
 * This file is part of Flowplayer, http://flowplayer.org
 *
 * By: Daniel Rossi, <electroteque@gmail.com>
 * Copyright (c) 2009 Electroteque Multimedia
 *
 * Released under the MIT License:
 * http://www.opensource.org/licenses/mit-license.php
 */
package org.flowplayer.shareembed {
    import flash.display.DisplayObject;
    import flash.display.Sprite;
    import flash.events.FocusEvent;
    import flash.events.MouseEvent;
    import flash.system.System;
    import flash.text.TextField;
    import flash.text.TextFieldType;
    import flash.text.TextFormat;

    import org.flowplayer.model.DisplayPluginModel;
    import org.flowplayer.shareembed.config.Config;
    import org.flowplayer.ui.DropdownMenu;
    import org.flowplayer.ui.DropdownMenuEvent;
    import org.flowplayer.ui.LabelButton;
    import org.flowplayer.util.Arrange;
    import org.flowplayer.view.AnimationEngine;
    import org.flowplayer.view.Flowplayer;

    /**
     * @author danielr
     */
    internal class EmbedView extends StyleableView {

        private var _embedCode:TextField;
        private var _copyBtn:LabelButton;
        private var _titleLabel:TextField;
        private var _optionsLabel:TextField;
        private var _buttonColorLabel:TextField;
        private var _bgColorLabel:TextField;
        private var _sizeDivLabel:TextField;
        private var _sizeLabel:TextField;
        private var _config:Config;
        private var _bgColors:DropdownMenu;
        private var _buttonColors:DropdownMenu;
        private var _heightTxt:TextField;
        private var _widthTxt:TextField;
        private var _optionsContainer:Sprite;

        public function EmbedView(plugin:DisplayPluginModel, player:Flowplayer, config:Config, style:Object) {
            super("viral-embed", plugin, player, style);
            _config = config;

            createCopyButton();
            createEmbedCode();
            createOptionsContainer();

            _titleLabel = createLabel("<span class=\"title\">" + _config.embed.title + "</span>");
            _optionsLabel = createLabel("<span class=\"label\">" + _config.embed.options + "</span>", _optionsContainer);
            _sizeLabel = createLabel("<span class=\"label\">" + _config.embed.size + "</span>", _optionsContainer);
            _bgColorLabel = createLabel("<span class=\"label\">" + _config.embed.backgroundColor + "</span>", _optionsContainer);
            _buttonColorLabel = createLabel("<span class=\"label\">" + _config.embed.buttonColor + "</span>", _optionsContainer);
            _sizeDivLabel = createLabel("<span class=\"label\">x</span>", _optionsContainer);

            _widthTxt = createInput(_optionsContainer, 2);
            log.debug("setting embed size to " + _config.embed.playerEmbed.width + " x " + _config.embed.playerEmbed.height);
            _widthTxt.text = _config.embed.playerEmbed.width + "";
            _widthTxt.addEventListener(FocusEvent.FOCUS_OUT, function(event:FocusEvent):void {
                config.embed.playerEmbed.width = value(_widthTxt);
                changeCode();
            });

            _heightTxt = createInput(_optionsContainer, 3);
            _heightTxt.text = _config.embed.playerEmbed.height + "";
            _heightTxt.addEventListener(FocusEvent.FOCUS_OUT, function(event:FocusEvent):void {
                config.embed.playerEmbed.height = value(_heightTxt);
                changeCode();
            });

            createButtonColorMenu(player.animationEngine);
            createBackgroundColorMenu(player.animationEngine);
            initEmbedCodeSettings();
        }

        override public function set visible(value:Boolean):void {
            super.visible = value;
            _config.embed.playerEmbed.applyControlsOptions(value);
        }

        private function value(field:TextField):int {
            try {
                return int(field.text);
            } catch (e:Error) {
                log.warn(e.message);
            }
            return 0;
        }

        private function createOptionsContainer():void {
            _optionsContainer = new Sprite();
            addChild(_optionsContainer);
        }


        private function createButtonColorMenu(animationEngine:AnimationEngine):void {
            _buttonColors = new DropdownMenu(animationEngine);
            _buttonColors.addItem("White", "#ffffff");
            _buttonColors.addItem("Black", "#000000");
            _buttonColors.addItem("Red", "#ff0000");
            _buttonColors.addItem("Blue", "#0000ff");
            _buttonColors.addItem("Yellow", "#ffff00");
            _buttonColors.addItem("Green", "#0C9607");
            _buttonColors.addEventListener(DropdownMenuEvent.CHANGE, function(event:DropdownMenuEvent):void {
                _config.embed.playerEmbed.buttonColor = event.value;
                changeCode();
            });
            _optionsContainer.addChild(_buttonColors);
        }

        private function createBackgroundColorMenu(animationEngine:AnimationEngine):void {
            _bgColors = new DropdownMenu(animationEngine);
            _bgColors.addItem("Black", "#000000");
            _bgColors.addItem("Transparent", "rgba(0,0,0,0)");
            _bgColors.addItem("Blue", "#0000ff");
            _bgColors.addItem("Blue transparent", "rgba(0, 0, 255, 0.6)");
            _bgColors.addItem("Yellow", "#D5D537");
            _bgColors.addItem("Yellow transparent", "rgba(223, 213, 55, 0.6)");
            _bgColors.addItem("Green", "#0C9607");
            _bgColors.addItem("Green transparent", "rgba(12, 150, 07, 0.6)");
            _bgColors.addEventListener(DropdownMenuEvent.CHANGE, function(event:DropdownMenuEvent):void {
                _config.embed.playerEmbed.backgroundColor = event.value;
                changeCode();
            });
            _optionsContainer.addChild(_bgColors);
        }

        private function setSelection():void {
            _embedCode.setSelection(0, _embedCode.text.length);
            _embedCode.scrollH = _embedCode.scrollV = 0;
        }

        private function createLabel(htmlText:String, parent:DisplayObject = null):TextField {
            var field:TextField = createLabelField();
            field.htmlText = htmlText;
            (parent ? parent : this).addChild(field);
            return field;
        }

        private function createInput(parent:DisplayObject = null, tabIndex:int = 0):TextField {
            var field:TextField = createInputField();
            (parent ? parent : this).addChild(field);
            if (tabIndex > 0) {
                field.tabIndex = tabIndex;
            }
            return field;
        }

        private function changeCode():void {
            log.debug("changeCode");
            _embedCode.htmlText = '<span class="embed">' + _config.embed.playerEmbed.getEmbedCode().replace(/\</g, "&lt;").replace(/\>/g, "&gt;") + '</span>';
        }

        private function initEmbedCodeSettings():void {
            _config.embed.playerEmbed.width = _widthTxt.text as Number;
            _config.embed.playerEmbed.height = _heightTxt.text as Number;
            changeCode();
        }

        private function createEmbedCode():void {
            if (_embedCode) {
                removeChild(_embedCode);
            }
            _embedCode = createInputField(true);
            _embedCode.type = TextFieldType.DYNAMIC;
            _embedCode.selectable = false;
            var format:TextFormat = new TextFormat();
            format.size = 10;
            _embedCode.defaultTextFormat = format;

            addChild(_embedCode);
        }

        private function arrangeOptions():void {
            // Size: [width] x [height]
            const INPUT_LEFT:Number = 120;
            _optionsContainer.y = _copyBtn.y + _copyBtn.height + 10;

            _sizeLabel.y = _optionsLabel.height + PADDING_Y_TALL;
            _widthTxt.y = _optionsLabel.y;
            _widthTxt.x = INPUT_LEFT + 20;
            _widthTxt.y = _sizeLabel.y;
            _widthTxt.width = 50;
            _sizeDivLabel.x = _widthTxt.x + _widthTxt.width + 3;
            _sizeDivLabel.y = _widthTxt.y;
            _heightTxt.x = _sizeDivLabel.x + _sizeDivLabel.width + 3;
            _heightTxt.y = _sizeLabel.y;
            _heightTxt.width = 50;

            _bgColorLabel.y = _widthTxt.y + _widthTxt.height + PADDING_Y_TALL;
            _bgColors.x = INPUT_LEFT;
            _bgColors.y = _bgColorLabel.y;
//            _bgColors.width = 200;
            _bgColors.width = _widthTxt.width + 6 + _heightTxt.width + _sizeDivLabel.width + 20;
            _bgColors.height = 20;

            _buttonColorLabel.y = _bgColors.y + _bgColors.height + PADDING_Y_TALL;
            _buttonColors.x = INPUT_LEFT;
            _buttonColors.y = _buttonColorLabel.y;
            _buttonColors.width = _bgColors.width;
            _buttonColors.height = 20;

            Arrange.center(_optionsContainer, width);
        }

        override protected function onResize():void {
            log.debug("onResize " + width + " x " + height);
            _titleLabel.y = 20;
            _titleLabel.width = _titleLabel.textWidth;
            _titleLabel.x = MARGIN_X;

            _embedCode.width = width - 2 * MARGIN_X;
            _embedCode.height = 15;
            _embedCode.x = MARGIN_X;
            _embedCode.y = _titleLabel.y + _titleLabel.height + 10;

            _copyBtn.setSize(130, 30);
            _copyBtn.x = width - _copyBtn.width - MARGIN_X;
            _copyBtn.y = _embedCode.y + _embedCode.height + 10;

            arrangeOptions();
            setSelection();
        }

        private function createCopyButton():void {
            _copyBtn = new LabelButton(_config.embed.copy, _config.buttons, player.animationEngine);
            _copyBtn.tabEnabled = true;
            _copyBtn.tabIndex = 1;
            _copyBtn.addEventListener(MouseEvent.CLICK, onCopyToClipboard);
            addChild(_copyBtn);
        }

        private function onCopyToClipboard(event:MouseEvent):void {
            initEmbedCodeSettings();
            System.setClipboard(_config.embed.playerEmbed.getEmbedCode());
            stage.focus = _embedCode;
            setSelection();
            _titleLabel.htmlText = '<span class="info">Copied to clipboard</span>';
        }
    }
}
