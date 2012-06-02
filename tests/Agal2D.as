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
	
	public class Agal2D
	{
		private var indexBuffer:IndexBuffer3D;
		private var numChildChange:Boolean = true;
		internal var numChild:int = 0;
		private var frist:Sprite2D;
		private var end:Sprite2D;
		//private var vertexData:Vector.<Number> = new Vector.<Number>;
		private var uvData:Vector.<Number> = new Vector.<Number>;
		private var transformData:Vector.<Number> = new Vector.<Number>;
		private var transformData2:Vector.<Number> = new Vector.<Number>;
		private var transformData3:Vector.<Number> = new Vector.<Number>;
		private var indexData:Vector.<uint> = new Vector.<uint>;
		//private var lengthPerVertex:int = 3 * 4;
		private var lengthPerUv:int = 2 * 4;
		private var lengthPerTransform:int = 3*4;
		private var lengthPerTransform2:int = 3*4;
		private var lengthPerTransform3:int = 3*4;
		private var lengthPerIndex:int = 6 * 4;
		private var t1buf:VertexBuffer3D;
		private var t2buf:VertexBuffer3D;
		private var t3buf:VertexBuffer3D;
		private var uvBuffer:VertexBuffer3D;
		private var view:Stage3dView;
		public function Agal2D(view:Stage3dView)
		{
			this.view = view;
		}
		
		internal function enterFrameHandler():void
		{
			if (numChildChange)
			{
				if (t1buf)
					t1buf.dispose();
				if (t2buf)
					t2buf.dispose();
				if (t3buf)
					t3buf.dispose();
				if (uvBuffer)
					uvBuffer.dispose();
				if (indexBuffer)
					indexBuffer.dispose();
				t1buf = view.context3D.createVertexBuffer(numChild * 4, 3);
				t2buf = view.context3D.createVertexBuffer(numChild * 4, 3);
				t3buf = view.context3D.createVertexBuffer(numChild * 4, 3);
				uvBuffer = view.context3D.createVertexBuffer(numChild * 4, 2);
				indexBuffer = view.context3D.createIndexBuffer(numChild * 6);
				uvBuffer.uploadFromVector(uvData, 0, numChild * 4);
				indexBuffer.uploadFromVector(indexData, 0, numChild * 6);
				numChildChange = false;
			}
			view.context3D.setVertexBufferAt(0, t1buf, 0, Context3DVertexBufferFormat.FLOAT_3);
			view.context3D.setVertexBufferAt(1, t2buf, 0, Context3DVertexBufferFormat.FLOAT_3);
			view.context3D.setVertexBufferAt(2, t3buf, 0, Context3DVertexBufferFormat.FLOAT_3);
			view.context3D.setVertexBufferAt(3, uvBuffer, 0, Context3DVertexBufferFormat.FLOAT_2);
			var current:Sprite2D = frist;
			while (current)
			{
				current.radian += 0.05;
				current = current.next;
			}
			
			t1buf.uploadFromVector(transformData, 0, numChild * 4);
			t2buf.uploadFromVector(transformData2, 0, numChild * 4);
			t3buf.uploadFromVector(transformData3, 0, numChild * 4);
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
			c = lengthPerTransform3;
			while (c-- > 0)
				transformData3.push(0);
			
			//sprite.vertexPointer = numChild * lengthPerVertex;
			sprite.uvPointer = numChild * lengthPerUv;
			sprite.transformPointer = numChild * lengthPerTransform;
			sprite.transformPointer2 = numChild * lengthPerTransform2;
			sprite.transformPointer3 = numChild * lengthPerTransform3;
			//sprite.vertexData = vertexData;
			sprite.uvData = uvData;
			sprite.transformData = transformData;
			sprite.transformData2 = transformData2;
			sprite.transformData3 = transformData3;
			sprite.x = view.w * Math.random();
			sprite.y = view.h * Math.random();
			sprite.z = Math.random();////1- 1 / view.num;
			sprite.scaleX = sprite.scaleY =   Math.random() * 2 + .5;
			sprite.radian = Math.PI * 2 * Math.random();
			sprite.width = sprite.height = 50;
			sprite.left = sprite.top = -25;
			
			indexData.push(numChild * 4, numChild * 4 + 1, numChild * 4 + 2, numChild * 4, numChild * 4 + 2, numChild * 4 + 3);
			//vertexData.push(0, 0, sprite.z, 0, 0, sprite.z, 0, 0, sprite.z, 0, 0, sprite.z);
			uvData.push(0, 1, 0, 0, 1, 0, 1, 1);
			sprite.updateSelf();
			
			numChild++;
		}
	}
}

class Sprite2D
{
	//internal var vertexData:Vector.<Number>;//x y z world
	internal var uvData:Vector.<Number>;//u v
	internal var transformData:Vector.<Number>;//x y z self
	internal var transformData2:Vector.<Number>;// sx sy r
	internal var transformData3:Vector.<Number>;//x y z offset
	//internal var vertexPointer:int;
	internal var uvPointer:int;
	internal var transformPointer:int;
	internal var transformPointer2:int;
	internal var transformPointer3:int;
	internal var vx:Number;
	internal var vy:Number;
	internal var next:Sprite2D;
	internal var _width:Number;
	internal var _height:Number;
	internal var _left:Number;
	internal var _top:Number;
	internal var selfChange:Boolean = true;
	
	internal function get x():Number
	{
		return transformData[transformPointer];
	}
	
	internal function set x(value:Number):void
	{
		transformData[transformPointer]=transformData[transformPointer+3]=transformData[transformPointer+6]=transformData[transformPointer+9] = value;
	}
	
	internal function get y():Number
	{
		return transformData[transformPointer + 1];
	}
	
	internal function set y(value:Number):void
	{
		transformData[transformPointer+1]=transformData[transformPointer+4]=transformData[transformPointer+7]=transformData[transformPointer+10] = value;
	}
	
	internal function get z():Number
	{
		return transformData[transformPointer + 2];
	}
	
	internal function set z(value:Number):void
	{
		transformData[transformPointer+2]=transformData[transformPointer+5]=transformData[transformPointer+8]=transformData[transformPointer+11] = value;
	}
	
	
	
	internal function get scaleX():Number
	{
		return transformData2[transformPointer2];
	}
	
	internal function set scaleX(value:Number):void
	{
		transformData2[transformPointer2]=transformData2[transformPointer2+3]=transformData2[transformPointer2+6]=transformData2[transformPointer2+9] = value;
	}
	
	internal function get scaleY():Number
	{
		return transformData2[transformPointer2 + 1];
	}
	
	internal function set scaleY(value:Number):void
	{
		transformData2[transformPointer2+1]=transformData2[transformPointer2+4]=transformData2[transformPointer2+7]=transformData2[transformPointer2+10] = value;
	}
	
	internal function get radian():Number
	{
		return transformData2[transformPointer2 + 2];
	}
	
	internal function set radian(value:Number):void
	{
		transformData2[transformPointer2+2]=transformData2[transformPointer2+5]=transformData2[transformPointer2+8]=transformData2[transformPointer2+11] = value;
	}
	
	internal function get width():Number
	{
		return _width;
	}
	
	internal function set width(value:Number):void
	{
		_width = value;
		selfChange = true;
	}
	
	internal function get height():Number
	{
		return _height;
	}
	
	internal function set height(value:Number):void
	{
		_height = value;
		selfChange = true;
	}
	
	internal function get left():Number
	{
		return _left;
	}
	
	internal function set left(value:Number):void
	{
		_left = value;
		selfChange = true;
	}
	
	internal function get top():Number
	{
		return _top;
	}
	
	internal function set top(value:Number):void
	{
		_top = value;
		selfChange = true;
	}
	
	internal function updateSelf():void {
		transformData3[transformPointer3] = _left;
		transformData3[transformPointer3 + 1] = -_top;
		
		transformData3[transformPointer3 + 3] = _left
		transformData3[transformPointer3 + 4] = -_top-_height;
		
		transformData3[transformPointer3 + 6] = _left+_width;
		transformData3[transformPointer3 + 7] = -_top - _height;
		
		transformData3[transformPointer3 + 9] = _left + _width;
		transformData3[transformPointer3 + 10] = -_top;
	}
	
	
}