package  
{
	import flash.display.Graphics;
	/**
	 * ...
	 * @author lizhi
	 */
	public class Player 
	{
		public var x:Number;
		public var y:Number;
		public var vx:Number=0;
		public var vy:Number=0;
		private var _left:Number=-5;
		private var _right:Number=5;
		private var _top:Number=-10;
		private var _bottom:Number=0;
		public var gravity:Number = 0.5;
		public var isInGround:Boolean = false;
		public var secondJump:Boolean = false;
		public function Player() 
		{
			
		}
		
		public function draw(g:Graphics):void {
			g.beginFill(0xff0000);
			g.drawRect(left, top,right - left+1, bottom - top+1);
			g.endFill();
		}
		
		public function get left():Number 
		{
			return _left+x;
		}
		
		public function get right():Number 
		{
			return _right+x;
		}
		
		public function set left(value:Number):void 
		{
			x += value-left;
		}
		
		public function set right(value:Number):void 
		{
			x += value-right;
		}
		
		public function get top():Number 
		{
			return _top+y;
		}
		
		public function set top(value:Number):void 
		{
			y += value-top;
		}
		
		public function get bottom():Number 
		{
			return _bottom+y;
		}
		public function set bottom(value:Number):void 
		{
			y += value-bottom;
		}
	}

}