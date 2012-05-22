package  
{
	import flash.display.Graphics;
	/**
	 * ...
	 * @author lizhi
	 */
	public class EndBox extends Box
	{
		
		public function EndBox(x:Number,y:Number) 
		{
			super(x, y);
		}
		
		override public function inside(player:Player):void {
			
		}
		
		override public function conleft(player:Player):void {
			
		}
		
		override public function conright(player:Player):void {
			
		}
		
		override public function contop(player:Player):void {
			
		}
		
		override public function conbottom(player:Player):void {
			
		}
		
		override public function darw(g:Graphics):void {
			g.beginFill(0xff0000);
			g.drawRect(left, top, 50, 50);
			g.endFill();
		}
		
	}

}