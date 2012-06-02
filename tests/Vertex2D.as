package
{
	import com.adobe.utils.*;
	import flash.display.*;
	import flash.display3D.*;
	import flash.display3D.textures.*;
	import flash.events.*;
	import flash.geom.Matrix3D;
	import flash.utils.*;
	import net.game_develop.animation.utils.*;
	
	[SWF(framerate=60,width=800,height=800)]
	
	public class Vertex2D
	{
		private var indexBuffer:IndexBuffer3D;
		private var numChildChange:Boolean = true;
		internal var numChild:int = 0;
		private var frist:Sprite2D;
		private var end:Sprite2D;
		private var vertexData:Vector.<Number> = new Vector.<Number>;
		private var uvData:Vector.<Number> = new Vector.<Number>;
		private var transformData:Vector.<Number> = new Vector.<Number>;
		private var transformData2:Vector.<Number> = new Vector.<Number>;
		private var indexData:Vector.<uint> = new Vector.<uint>;
		private var lengthPerVertex:int = 3 * 4;
		private var lengthPerUv:int = 2 * 4;
		private var lengthPerTransform:int = 4;
		private var lengthPerTransform2:int = 7;
		private var lengthPerIndex:int = 6 * 4;
		private var vertexBuffer:VertexBuffer3D;
		private var uvBuffer:VertexBuffer3D;
		private var view:Stage3dView;
		
		
		public function Vertex2D(view:Stage3dView)
		{
			this.view = view;
			
		}
		
		internal function enterFrameHandler():void
		{
			if (numChildChange)
			{
				if (vertexBuffer)
					vertexBuffer.dispose();
				if (uvBuffer)
					uvBuffer.dispose();
				if (indexBuffer)
					indexBuffer.dispose();
				vertexBuffer = view.context3D.createVertexBuffer(numChild * 4, 3);
				uvBuffer = view.context3D.createVertexBuffer(numChild * 4, 2);
				indexBuffer = view.context3D.createIndexBuffer(numChild * 6);
				uvBuffer.uploadFromVector(uvData, 0, numChild * 4);
				indexBuffer.uploadFromVector(indexData, 0, numChild * 6);
				numChildChange = false;
			}
			view.context3D.setVertexBufferAt(0, vertexBuffer, 0, Context3DVertexBufferFormat.FLOAT_3);
			view.context3D.setVertexBufferAt(1, uvBuffer, 0, Context3DVertexBufferFormat.FLOAT_2);
			var current:Sprite2D = frist;
			while (current)
			{
				current.radian += 0.05;
				if(current.change){
					var cosT:Number = Math.cos(current.radian);
					var sinT:Number = Math.sin(current.radian);
					var sx:Number = current.left * current.scaleX;
					var sy:Number = -current.top * current.scaleY;
					var dx:Number = current.width * current.scaleX;
					var dy:Number = -current.height * current.scaleY;
					var dcy:Number = cosT * dy;
					var dsy:Number = sinT * dy;
					var dcx:Number = cosT * dx;
					var dsx:Number = sinT * dx;
					var sox:Number = cosT * sx - sinT * sy + current.x;
					var soy:Number = cosT * sy + sinT * sx + current.y;
					vertexData[current.vertexPointer] = sox;
					vertexData[current.vertexPointer + 1] = soy;
					
					vertexData[current.vertexPointer + 3] = sox - dsy;
					vertexData[current.vertexPointer + 4] = soy + dcy;
					
					vertexData[current.vertexPointer + 6] = sox + dcx - dsy;
					vertexData[current.vertexPointer + 7] = soy + dcy + dsx;
					
					vertexData[current.vertexPointer + 9] = sox + dcx;
					vertexData[current.vertexPointer + 10] = soy + dsx;
					current.change = 0;
					current = current.next;
				}
			}
			vertexBuffer.uploadFromVector(vertexData, 0, numChild * 4);
			view.context3D.drawTriangles(indexBuffer);
		}
		
		internal function add():void
		{
			numChildChange = true;
			var sprite:Sprite2D = new Sprite2D;
			
			if (frist == null)
			{
				frist = end = sprite;
			}
			else
			{
				end.next = sprite;
				end = sprite;
			}
			
			var c:int = lengthPerTransform;
			while (c-- > 0)
				transformData.push(0);
			
			c = lengthPerTransform2;
			while (c-- > 0)
				transformData2.push(0);
			
			sprite.vertexPointer = numChild * lengthPerVertex;
			sprite.uvPointer = numChild * lengthPerUv;
			sprite.transformPointer = numChild * lengthPerTransform;
			sprite.transformPointer2 = numChild * lengthPerTransform2;
			sprite.vertexData = vertexData;
			sprite.uvData = uvData;
			sprite.transformData = transformData;
			sprite.transformData2 = transformData2;
			sprite.x = view.w * Math.random();
			sprite.y = view.h * Math.random();
			sprite.z = Math.random(); //1-(i+1) / (num+1);
			sprite.radian = Math.PI * 2 * Math.random();
			sprite.scaleX = sprite.scaleY = Math.random() * 2 + .5;
			sprite.width = sprite.height = 50;
			sprite.left = sprite.top = -25;
			
			indexData.push(numChild * 4, numChild * 4 + 1, numChild * 4 + 2, numChild * 4, numChild * 4 + 2, numChild * 4 + 3);
			
			vertexData.push(0, 0, sprite.z, 0, 0, sprite.z, 0, 0, sprite.z, 0, 0, sprite.z);
			
			uvData.push(0, 1, 0, 0, 1, 0, 1, 1);
			
			numChild++;
		}
	}
}

class Sprite2D
{
	internal var vertexData:Vector.<Number>;
	internal var uvData:Vector.<Number>;
	internal var transformData:Vector.<Number>;
	internal var transformData2:Vector.<Number>;
	internal var vertexPointer:int;
	internal var uvPointer:int;
	internal var transformPointer:int;
	internal var transformPointer2:int;
	internal var vx:Number;
	internal var vy:Number;
	internal var next:Sprite2D;
	
	internal function get x():Number
	{
		return transformData[transformPointer];
	}
	
	internal function set x(value:Number):void
	{
		transformData[transformPointer] = value;
		change = 1;
	}
	
	internal function get y():Number
	{
		return transformData[transformPointer + 1];
	}
	
	internal function set y(value:Number):void
	{
		transformData[transformPointer + 1] = value;
		change = 1;
	}
	
	internal function get z():Number
	{
		return transformData[transformPointer + 2];
	}
	
	internal function set z(value:Number):void
	{
		transformData[transformPointer + 2] = value;
		change = 1;
	}
	
	internal function get radian():Number
	{
		return transformData[transformPointer + 3];
	}
	
	internal function set radian(value:Number):void
	{
		transformData[transformPointer + 3] = value;
		change = 1;
	}
	
	internal function get scaleX():Number
	{
		return transformData2[transformPointer2];
	}
	
	internal function set scaleX(value:Number):void
	{
		transformData2[transformPointer2] = value;
		change = 1;
	}
	
	internal function get scaleY():Number
	{
		return transformData2[transformPointer2 + 1];
	}
	
	internal function set scaleY(value:Number):void
	{
		transformData2[transformPointer2 + 1] = value;
		change = 1;
	}
	
	internal function get width():Number
	{
		return transformData2[transformPointer2 + 2];
	}
	
	internal function set width(value:Number):void
	{
		transformData2[transformPointer2 + 2] = value;
		change = 1;
	}
	
	internal function get height():Number
	{
		return transformData2[transformPointer2 + 3];
	}
	
	internal function set height(value:Number):void
	{
		transformData2[transformPointer2 + 3] = value;
		change = 1;
	}
	
	internal function get left():Number
	{
		return transformData2[transformPointer2 + 4];
	}
	
	internal function set left(value:Number):void
	{
		transformData2[transformPointer2 + 4] = value;
		change = 1;
	}
	
	internal function get top():Number
	{
		return transformData2[transformPointer2 + 5];
	}
	
	internal function set top(value:Number):void
	{
		transformData2[transformPointer2 + 5] = value;
		change = 1;
	}
	
	public function get change():int 
	{
		return transformData2[transformPointer2 + 6];
	}
	
	public function set change(value:int):void 
	{
		transformData2[transformPointer2 + 6] = value;
	}
}