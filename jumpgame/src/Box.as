package  
{
	import flash.display.Graphics;
	/**
	 * ...
	 * @author lizhi
	 */
	public class Box 
	{
		public var left:Number;
		public var right:Number;
		public var top:Number;
		public var bottom:Number;
		public function Box(x:Number,y:Number) 
		{
			left = x * 50;
			top = y * 50;
			right = left + 49;
			bottom = top + 49;
		}
		
		public function inside(player:Player):void {
			
		}
		
		public function conleft(player:Player):void {
			
		}
		
		public function conright(player:Player):void {
			
		}
		
		public function contop(player:Player):void {
			
		}
		
		public function conbottom(player:Player):void {
			
		}
		
		public function darw(g:Graphics):void {
			g.beginFill(0);
			g.drawRect(left, top, 50, 50);
			g.endFill();
		}
	}

}