package {    import flash.display.DisplayObject;import flash.display.Sprite;    public class SkinDefaults extends Sprite {        public static function get values():Object {            return {                bottom: 0, left: 0, height: 24, width: "100%", zIndex: 2,                backgroundColor: "#25353C",                backgroundGradient: [.6, 0.3, 0, 0, 0],                border: "0px", borderRadius: "0px",                timeColor: "#01DAFF",                durationColor: "#ffffff",                sliderColor: "#000000",                sliderGradient: "none",                buttonColor: "#555555",                buttonOverColor: "#FF0000",                progressColor: "#015B7A",                progressGradient: "medium",                bufferColor: "#6c9cbc",                bufferGradient: "none",                tooltipColor: "#5F747C",                tooltipTextColor: "#ffffff",                timeBgColor: '#555555',                scrubberHeightRatio: 0.3,                scrubberBarHeightRatio: 0.3            }        }        public static function getSpaceAfterWidget(widget:DisplayObject):Number {            // we don't have any margins after any of the widgets            return 0;        }    }}