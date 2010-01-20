package {    import flash.display.DisplayObject;    public class SkinDefaults {        public static function get values():Object {            return {                bottom: 0, 				left: 0, 				height: 24, 				width: "100%", 				zIndex: 2,                backgroundColor: "#000000",                backgroundGradient: [.5, 0, 0.3],                border: "0px",                borderRadius: "0px",                timeColor: "#ffffff",                durationColor: "#a3a3a3",                sliderColor: "#ffffff",                sliderGradient: "none",				volumeColor: '#FF2127',                volumeSliderColor: "#FFFFFF",                volumeSliderGradient: "none",                buttonColor: "#ffffff",                buttonOverColor: "#ffffff",                progressColor: "#FF2127",                progressGradient: "none",                bufferColor: "#A8A8A8",                bufferGradient: "none",                tooltipColor: "#5F747C",                tooltipTextColor: "#ffffff",                timeBgColor: '#555555',				timeBorderRadius: 0,				// what percentage the scrubber handle should take of the controlbar total height                scrubberHeightRatio: 0.4,                // what percentage the scrubber horizontal bar should take of the controlbar total height                scrubberBarHeightRatio: 0.5,                // what percentage the volume slider handle should take of the controlbar total height                volumeSliderHeightRatio: 0.4,                // what percentage the horizontal volume bar should take of the controlbar total height                volumeBarHeightRatio: 0.5,                // how much the time view colored box is of the total controlbar height                timeBgHeightRatio: 0,				timeSeparator: "  ",				timeFontSize: 12            }        }        public static function getSpaceAfterWidget(widget:DisplayObject, widgetIsOnRightEdge:Boolean):Number {			var space:int = 4;            if (widgetIsOnRightEdge)                space = 0;            else if (widget.name == "volume")                space = 6;            else if (widget.name == "scrubber")                space = 3;            else if (widget.name == "time")                space = 2;            return space;        }        public static function getScrubberRightEdgeWidth(nextWidgetToRight:DisplayObject):Number {            return 0;        }        public static function get margins():Array {            return [2, 6, 2, 6];        }    }}