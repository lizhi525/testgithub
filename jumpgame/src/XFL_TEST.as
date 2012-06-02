package  
{
	import flash.display.Sprite;
	import flash.utils.ByteArray;
	/**
	 * ...
	 * @author lizhi
	 */
	public class XFL_TEST extends Sprite
	{
		private var xml:XML;
		
		public function XFL_TEST() 
		{
			graphics.lineStyle(0, 0xff0000);
			
			graphics.beginFill(0);
			
			graphics.moveTo(120, 180);
			graphics.lineTo(180, 180);
			graphics.moveTo(180, 180);
			graphics.lineTo(180, 120);
			graphics.moveTo(180, 120);
			graphics.lineTo(120, 120);
			graphics.moveTo(120, 120);
			graphics.lineTo(120, 180);
			
			graphics.moveTo(120, 120);
			graphics.lineTo(120, 180);
			graphics.moveTo(180, 120);
			graphics.lineTo(120, 120);
			graphics.moveTo(180, 180);
			graphics.lineTo(180, 120);
			graphics.moveTo(120, 180);
			graphics.lineTo(180, 180);
			
			
			
			
			
			
			/*graphics.moveTo(100, 100);
			graphics.lineTo(200, 100);
			graphics.lineTo(200, 200);
			graphics.lineTo(100, 200);
			graphics.lineTo(100, 100);*/
			
			return;
			[Embed(source = "../bin/DOMDocument.xml", mimeType = "application/octet-stream")]var c:Class;
			var a:ByteArray = new c as ByteArray;
			xml = XML(a.readUTFBytes(a.length));
			var list:XMLList = xml.*::timelines.*::DOMTimeline.*::layers.*::DOMLayer.*::frames.*::DOMFrame.*::elements.*::DOMShape.*::edges.*::Edge;
			graphics.lineStyle(0);
			graphics.beginFill(0xff0000);
			var reg:RegExp=/([!,[,(,|,\/])|(#*\w*\.\w*)|(\d+)/g
			for each(var cxml:XML in list) {
				var str:String = cxml.@edges;
				var obj:Object;
				trace("s1",cxml.@fillStyle1,"s0",cxml.@fillStyle0);
				while (obj = reg.exec(str)) {
					var ec:String = obj[0];
					if (ec == "!") {
						var x0:Number = getNumber(reg.exec(str)[0]);
						var y0:Number = getNumber(reg.exec(str)[0]);
						trace("start", x0, y0);
						graphics.moveTo(x0,y0);
					}else if (ec == "[" || ec == "(") {
						var x1:Number = getNumber(reg.exec(str)[0]);
						var y1:Number = getNumber(reg.exec(str)[0]);
						var x2:Number = getNumber(reg.exec(str)[0]);
						var y2:Number = getNumber(reg.exec(str)[0]);
						if (String(cxml.@fillStyle1)!="") {
							//graphics.beginFill(getColor(cxml.@fillStyle1));
							graphics.curveTo(x1, y1, x2, y2);
						}
						graphics.moveTo(x0, y0);
						if (String(cxml.@fillStyle0) != "") {
							//graphics.beginFill(getColor(cxml.@fillStyle0),0);
							graphics.curveTo(x1, y1, x2, y2);
						}
					}else if (ec=="|"||ec=="/") {
						//graphics.beginFill(getColor(cxml.@fillStyle1));
						x1 = getNumber(reg.exec(str)[0]);
						y1 = getNumber(reg.exec(str)[0]);
						graphics.lineTo(x1, y1);
						trace("line",x1, y1);
					}else {
						throw "error";
					}
				}
			}
		}
		
		public function getNumber(str:String):Number {
			if (str.charAt(0) == "#") {
				str = str.replace(/^#/, "0x");
				str = str.replace(/\..*$/,"");
				var num:int = int(str);
				return num/20;
			}
			return Number(str)/20;
		}
		
		private function getColor(index:String):uint {
			var str:String = xml.*::timelines.*::DOMTimeline.*::layers.*::DOMLayer.*::frames.*::DOMFrame.*::elements.*::DOMShape.*::fills.*::FillStyle.(@index == index).*::SolidColor.@color;
			str = str.replace(/^#/, "0x");
			return  uint(str);
		}
	}

}