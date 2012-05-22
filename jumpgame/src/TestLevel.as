package  
{
	import com.bit101.components.PushButton;
	import com.bit101.components.TextArea;
	import flash.display.Shader;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.geom.Rectangle;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.system.System;
	import flash.xml.XMLParser;
	/**
	 * ...
	 * @author lizhi
	 */
	public class TestLevel extends Sprite
	{
		private var player:Player;
		private var grid:Array = [];
		private var numCols:int;
		private var debug:Shape;
		private var input:Joystick;
		private var numLevel:int = 3;
		private var levels:Array = [];
		private var loaderindex:int = -1;
		private var levelindex:int = -1;
		
		private var game:Sprite = new Sprite;
		private var ta:TextArea;
		public function TestLevel() 
		{
			loadnext();
		}
		
		private function loadnext():void 
		{
			loaderindex++;
			if (loaderindex >= numLevel) {
				init();
				nextlevel();
			}else{
				var loader:URLLoader = new URLLoader(new URLRequest("leveltest/LIBRARY/levels/level" + loaderindex + ".xml"));
				loader.addEventListener(Event.COMPLETE, loader_complete);
				loader.addEventListener(IOErrorEvent.IO_ERROR, loader_ioError);
			}
		}
		
		private function loader_ioError(e:IOErrorEvent):void 
		{
			loadnext();
		}
		
		private function loader_complete(e:Event):void 
		{
			levels.push(XML((e.currentTarget as URLLoader).data));
			loadnext();
		}
		
		private function init():void{
			debug = new Shape;
			addChild(debug);
			addEventListener(Event.ENTER_FRAME, enterFrame);
			input = new Joystick;
			addChild(input);
			addChild(game);
			ta = new TextArea(this, 0, 0, "黏贴关卡代码");
			new PushButton(this,0,100,"自定义关卡",setxml);
		}
		
		private function setxml(e:Event):void 
		{
			var xml:XML = XML(ta.text);
			levels = [xml];
			nextlevel();
		}
		
		private function enterFrame(e:Event):void 
		{
			game.graphics.clear();
			var isInGround:Boolean = false;
			var leftgx:int = player.left / 50;
			var rightgx:int = player.right / 50;
			var gxs:Array = [leftgx];
			if (leftgx != rightgx) gxs.push(rightgx);
			
			player.vy += player.gravity;
			if (player.isInGround&&input.a) {
				player.vy = -11;
				player.isInGround = false;
			}else if (!player.isInGround&&!input.a&&player.vy<0) {
				player.vy = 0;
			}
			player.vy = Math.min(50, player.vy);
			
			if(player.vy){
				if (player.vy > 0) {
					var tgy:int = (player.bottom + player.vy + 1) / 50;
					for each(var gx:int in gxs) {
						var box:Box = grid[tgy * numCols + gx];
						if (box) {
							isInGround = true;
							if (box is EndBox) {
								nextlevel();
								return;
							}
						}
					}
				}else {
					var collideTop:Boolean = false;
					tgy = (player.top + player.vy - 1) / 50;
					for each(gx in gxs) {
						box = grid[tgy * numCols + gx];
						if (box) {
							collideTop = true;
							if (box is EndBox) {
								nextlevel();
								return;
							}
						}
					}
				}
			}
			
			if (isInGround) {
				player.vy = 0;
				player.bottom = tgy * 50 - 1;
			}else if (collideTop) {
				player.vy = 0;
				player.top = (tgy + 1) * 50;
			}else{
				player.y += player.vy;
			}
			
			player.isInGround = isInGround;
			
			if (input.left) {
				player.vx = -3;
			}else if (input.right) {
				player.vx = 3;
			}else {
				player.vx = 0;
			}
			if (player.vx) {
				var topgy:int = player.top / 50;
				var bottomgy:int = player.bottom / 50;
				var gys:Array = [topgy];
				if (topgy != bottomgy) gys.push(bottomgy);
				var collideX:Boolean = false;
				if(player.vx>0)var tgx:int = (player.right + player.vx + 1) / 50;
				else tgx = (player.left + player.vx -1) / 50;
				for each(var gy:int in gys) {
					box = grid[gy * numCols + tgx];
					if (box) {
						collideX = true;
						if (box is EndBox) {
							nextlevel();
							return;
						}
					}
				}
				if (collideX) {
					if (player.vx > 0) {
						player.right = tgx * 50 - 1;
					}else {
						player.left = (tgx+1) * 50;
					}
				}else{
					player.x += player.vx;
				}
			
			}
			
			player.draw(game.graphics);
			for each(box in grid) {
				box.darw(game.graphics);
			}
			if (game.x+player.x<stage.stageWidth/3) {
				game.x = stage.stageWidth / 3 - player.x;
			}
			if (game.x+player.x>2*stage.stageWidth/3) {
				game.x = 2*stage.stageWidth / 3 - player.x;
			}
			if (game.y+player.y<stage.stageWidth/3) {
				game.y = stage.stageWidth / 3 - player.y;
			}
			if (game.y+player.y>2*stage.stageHeight/3) {
				game.y = 2*stage.stageHeight / 3 - player.y;
			}
		}
		
		public function nextlevel():void {
			levelindex++;
			if (levelindex>=levels.length) {
				levelindex = 0;
			}
			
			grid = [];
			var xml:XML = levels[levelindex];
			ta.text = xml;
			var list:XMLList = xml.*::timeline.*::DOMTimeline.*::layers.*::DOMLayer.*::frames.*::DOMFrame.*::elements.*::DOMSymbolInstance;
			numCols = 0;
			for each(var cxml:XML in list) {
				numCols = Math.max(numCols, int((cxml.*::matrix.*::Matrix.@tx) / 50) + 1);
			}
			for each(cxml in list) {
				var name:String = cxml.@libraryItemName;
				var x:int = (cxml.*::matrix.*::Matrix.@tx)/50;
				var y:int = (cxml.*::matrix.*::Matrix.@ty) / 50;
				if(name=="objs/stone"){
					var box:Box = new Box(x, y);
					grid[y * numCols + x] = box;
				}else if(name=="objs/start"){
					player = new Player;
					player.x = cxml.*::matrix.*::Matrix.@tx;
					player.y = cxml.*::matrix.*::Matrix.@ty;
				}else if (name=="objs/end") {
					box = new EndBox(x, y);
					grid[y * numCols + x] = box;
				}
			}
		}
		
	}

}