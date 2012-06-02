package
{
	import com.adobe.utils.*;
	import com.doswf.alchemy.Memory;
	import flash.display.*;
	import flash.display3D.*;
	import flash.display3D.textures.*;
	import flash.events.*;
	import flash.geom.Matrix3D;
	import flash.system.ApplicationDomain;
	import flash.utils.*;
	import net.game_develop.animation.utils.*;
	
	[SWF(framerate=60,width=800,height=800)]
	
	public class Bytes2D extends Sprite
	{
		private var stage3D:Stage3D;
		private var w:Number;
		private var h:Number;
		private var context3D:Context3D;
		private var indexBuffer:IndexBuffer3D;
		private var numChildChange:Boolean = true;
		private var numChild:int = 0;
		private var frist:Sprite2D;
		private var end:Sprite2D;
		private var memory:ByteArray = new ByteArray;
		private var vertexPointer:int=0;
		private var uvPointer:int=1000000;
		private var transform1Pointer:int=2000000;
		private var transform2Pointer:int=3000000;
		/*private var vertexData:ByteArray = new ByteArray;
		private var uvData:ByteArray = new ByteArray;
		private var transformData:ByteArray = new ByteArray;
		private var transformData2:ByteArray = new ByteArray;*/
		private var indexData:Vector.<uint> = new Vector.<uint>;
		private var lengthPerVertex:int = 3 * 4 * 4;
		private var lengthPerUv:int = 2 * 4 * 4;
		private var lengthPerTransform:int = 4 * 4;
		private var lengthPerTransform2:int = 6 * 4;
		private var lengthPerIndex:int = 6 * 4;
		private var vertexBuffer:VertexBuffer3D;
		private var uvBuffer:VertexBuffer3D;
		private var camera:Matrix3D;
		
		public function Bytes2D()
		{
			addEventListener(Event.ADDED_TO_STAGE, onAdded);
			addChild(new Stats);
			memory.endian = Endian.LITTLE_ENDIAN;
			memory.length =     ApplicationDomain.MIN_DOMAIN_MEMORY_LENGTH;
			ApplicationDomain.currentDomain.domainMemory = memory;
			/*vertexData.endian = Endian.LITTLE_ENDIAN;
			uvData.endian = Endian.LITTLE_ENDIAN;
			transformData.endian = Endian.LITTLE_ENDIAN;
			transformData2.endian = Endian.LITTLE_ENDIAN;*/
			//uvData.length = transformData.length = transformData2.length = vertexData.length = ApplicationDomain.MIN_DOMAIN_MEMORY_LENGTH;
		}
		
		private function onAdded(pEvent:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, onAdded);
			initStage3D();
		}
		
		private function initStage3D():void
		{
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			
			w = 800;
			h = 400;
			
			stage3D = stage.stage3Ds[0];
			stage3D.addEventListener(Event.CONTEXT3D_CREATE, contextReady);
			stage3D.requestContext3D(Context3DRenderMode.AUTO);
		}
		
		private function contextReady(pEvent:Event):void
		{
			[Embed(source="orbz_002.png")]
			var bc:Class;
			var bmd:BitmapData = Bitmap(new bc).bitmapData;
			
			context3D = stage3D.context3D;
			context3D.configureBackBuffer(w, h, 0, true);
			
			camera = new Matrix3D;
			camera.appendScale(2 / w, -2 / h, 1);
			camera.appendTranslation(-1, 1, 0);
			context3D.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 0, camera, true);
			
			var texture:Texture = context3D.createTexture(bmd.width, bmd.height, Context3DTextureFormat.BGRA, true);
			texture.uploadFromBitmapData(bmd);
			context3D.setTextureAt(0, texture);
			
			var vertexAssembler:AGALMiniAssembler = new AGALMiniAssembler();
			vertexAssembler.assemble(Context3DProgramType.VERTEX, "m44 op,va0,vc0\n" + "mov v0,va1");
			
			var fragmentAssembler:AGALMiniAssembler = new AGALMiniAssembler();
			context3D.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0, Vector.<Number>([0, 0, 0, 0.00005]));
			fragmentAssembler.assemble(Context3DProgramType.FRAGMENT, "tex ft0, v0, fs0 <2d,linear,nomip>\nsub ft0.w,ft0.w,fc0.w\nkil ft0.w\nmov oc,ft0");
			//fragmentAssembler.assemble(Context3DProgramType.FRAGMENT, "tex oc, v0, fs0 <2d,linear,nomip>");
			
			var program:Program3D = context3D.createProgram();
			program.upload(vertexAssembler.agalcode, fragmentAssembler.agalcode);
			context3D.setProgram(program);
			
			addEventListener(Event.ENTER_FRAME, enterFrameHandler);
			
			var num:int = 10000;
			while(num-->0)
			add();
		}
		
		private function enterFrameHandler(pEvent:Event):void
		{
			if (numChildChange)
			{
				if (vertexBuffer)
					vertexBuffer.dispose();
				if (uvBuffer)
					uvBuffer.dispose();
				if (indexBuffer)
					indexBuffer.dispose();
				vertexBuffer = context3D.createVertexBuffer(numChild * 4, 3);
				uvBuffer = context3D.createVertexBuffer(numChild * 4, 2);
				indexBuffer = context3D.createIndexBuffer(numChild * 6);
				uvBuffer.uploadFromByteArray(memory, uvPointer, 0, numChild * 4);
				indexBuffer.uploadFromVector(indexData, 0, numChild * 6);
				context3D.setVertexBufferAt(0, vertexBuffer, 0, Context3DVertexBufferFormat.FLOAT_3);
				context3D.setVertexBufferAt(1, uvBuffer, 0, Context3DVertexBufferFormat.FLOAT_2);
				numChildChange = false;
			}
			//if(numChildChange){
			var current:Sprite2D = frist;
			while (current)
			{
				current.radian += 0.05;
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
				Memory.setFloat(sox,current.vertexPointer);
				Memory.setFloat(soy,current.vertexPointer + 4 );
				Memory.setFloat(sox - dsy,current.vertexPointer+12 );
				Memory.setFloat(soy + dcy,current.vertexPointer + 16 );
				Memory.setFloat(sox + dcx - dsy,current.vertexPointer+24 );
				Memory.setFloat(soy + dcy + dsx,current.vertexPointer + 28 );
				Memory.setFloat(sox + dcx,current.vertexPointer+36 );
				Memory.setFloat(soy + dsx,current.vertexPointer + 40 );
				/*vertexData.position = current.vertexPointer;
				vertexData.writeFloat(sox);
				vertexData.writeFloat(soy);
				vertexData.position = current.vertexPointer + 12;
				vertexData.writeFloat(sox - dsy);
				vertexData.writeFloat(soy + dcy);
				vertexData.position = current.vertexPointer + 24;
				vertexData.writeFloat(sox + dcx - dsy);
				vertexData.writeFloat(soy + dcy + dsx);
				vertexData.position = current.vertexPointer + 36;
				vertexData.writeFloat(sox + dcx);
				vertexData.writeFloat(soy + dsx);*/
				current = current.next;
			}
			//numChildChange = false;
			//}
			vertexBuffer.uploadFromByteArray(memory, vertexPointer, 0, numChild * 4);
			context3D.clear();
			context3D.drawTriangles(indexBuffer);
			context3D.present();
		}
		
		private function add():void
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
			
			sprite.vertexPointer = numChild * lengthPerVertex+vertexPointer;
			sprite.uvPointer = numChild * lengthPerUv+uvPointer;
			sprite.transformPointer = numChild * lengthPerTransform+transform1Pointer;
			sprite.transformPointer2 = numChild * lengthPerTransform2+transform2Pointer;
			/*sprite.vertexData = vertexData;
			sprite.uvData = uvData;
			sprite.transformData = transformData;
			sprite.transformData2 = transformData2;*/
			sprite.x = w * Math.random();
			sprite.y = h * Math.random();
			sprite.z = Math.random(); //1-(i+1) / (num+1);
			sprite.radian = Math.PI * 2 * Math.random();
			sprite.scaleX = sprite.scaleY = Math.random() * 2 + .5;
			sprite.width = sprite.height = 50;
			sprite.left = sprite.top = -25;
			
			indexData.push(numChild * 4, numChild * 4 + 1, numChild * 4 + 2, numChild * 4, numChild * 4 + 2, numChild * 4 + 3);
			
			//memory.position = sprite.vertexPointer + 40;
			//memory.writeByte(1);
			Memory.setFloat(sprite.z,sprite.vertexPointer + 8);
			Memory.setFloat(sprite.z,sprite.vertexPointer + 20);
			Memory.setFloat(sprite.z,sprite.vertexPointer + 32);
			Memory.setFloat(sprite.z,sprite.vertexPointer + 44);
			/*vertexData.position = sprite.vertexPointer + 8;
			vertexData.writeFloat(sprite.z);
			vertexData.position = sprite.vertexPointer + 20;
			vertexData.writeFloat(sprite.z);
			vertexData.position = sprite.vertexPointer + 32;
			vertexData.writeFloat(sprite.z);
			vertexData.position = sprite.vertexPointer + 44;
			vertexData.writeFloat(sprite.z);*/
			Memory.setFloat(0,sprite.uvPointer);
			Memory.setFloat(1,sprite.uvPointer+4);
			Memory.setFloat(0,sprite.uvPointer+8);
			Memory.setFloat(0,sprite.uvPointer+12);
			Memory.setFloat(1,sprite.uvPointer+16);
			Memory.setFloat(0,sprite.uvPointer+20);
			Memory.setFloat(1,sprite.uvPointer+24);
			Memory.setFloat(1,sprite.uvPointer+28);
			/*uvData.position = sprite.uvPointer;
			uvData.writeFloat(0);
			uvData.writeFloat(1);
			uvData.writeFloat(0);
			uvData.writeFloat(0);
			uvData.writeFloat(1);
			uvData.writeFloat(0);
			uvData.writeFloat(1);
			uvData.writeFloat(1);*/
			
			numChild++;
		}
	}
}

class Sprite2D
{
	/*internal var vertexData:flash.utils.ByteArray
	internal var uvData:flash.utils.ByteArray;
	internal var transformData:flash.utils.ByteArray;
	internal var transformData2:flash.utils.ByteArray;*/
	//internal var memory:ByteArray;
	internal var vertexPointer:int;
	internal var uvPointer:int;
	internal var transformPointer:int;
	internal var transformPointer2:int;
	internal var vx:Number;
	internal var vy:Number;
	internal var next:Sprite2D;
	
	internal function get x():Number
	{
		return com.doswf.alchemy.Memory.getFloat(transformPointer);
		//transformData.position = transformPointer;
		//return transformData.readFloat();
	}
	
	internal function set x(value:Number):void
	{
		com.doswf.alchemy.Memory.setFloat(value,transformPointer  );
		//transformData.position = transformPointer;
		//transformData.writeFloat(value);
	}
	
	internal function get y():Number
	{
		return com.doswf.alchemy.Memory.getFloat(transformPointer+4);
		//transformData.position = transformPointer + 4;
		//return transformData.readFloat();
	}
	
	internal function set y(value:Number):void
	{
		com.doswf.alchemy.Memory.setFloat(value,transformPointer + 4);
		//transformData.position = transformPointer + 4;
		//transformData.writeFloat(value);
	}
	
	internal function get z():Number
	{
		return com.doswf.alchemy.Memory.getFloat(transformPointer+8);
		//transformData.position = transformPointer + 8;
		//return transformData.readFloat();
	}
	
	internal function set z(value:Number):void
	{
		com.doswf.alchemy.Memory.setFloat(value,transformPointer + 8);
		//transformData.position = transformPointer + 8;
		//transformData.writeFloat(value);
	}
	
	internal function get radian():Number
	{
		return com.doswf.alchemy.Memory.getFloat(transformPointer+12);
		//transformData.position = transformPointer + 12;
		//return transformData.readFloat();
	}
	
	internal function set radian(value:Number):void
	{
		com.doswf.alchemy.Memory.setFloat(value,transformPointer + 12);
		//transformData.position = transformPointer + 12;
		//transformData.writeFloat(value);
	}
	
	internal function get scaleX():Number
	{
		return com.doswf.alchemy.Memory.getFloat(transformPointer2);
		//transformData2.position = transformPointer2;
		//return transformData2.readFloat();
	}
	
	internal function set scaleX(value:Number):void
	{
		com.doswf.alchemy.Memory.setFloat(value,transformPointer2 );
		//transformData2.position = transformPointer2;
		//transformData2.writeFloat(value);
	}
	
	internal function get scaleY():Number
	{
		return com.doswf.alchemy.Memory.getFloat(transformPointer2+4);
		//transformData2.position = transformPointer2 + 4;
		//return transformData2.readFloat();
	}
	
	internal function set scaleY(value:Number):void
	{
		com.doswf.alchemy.Memory.setFloat(value,transformPointer2 + 4);
		//transformData2.position = transformPointer2 + 4;
		//transformData2.writeFloat(value);
	}
	
	internal function get width():Number
	{
		return com.doswf.alchemy.Memory.getFloat(transformPointer2+8);
		//transformData2.position = transformPointer2 + 8;
		//return transformData2.readFloat();
	}
	
	internal function set width(value:Number):void
	{
		com.doswf.alchemy.Memory.setFloat(value,transformPointer2 + 8);
		//transformData2.position = transformPointer2 + 8;
		//transformData2.writeFloat(value);
	}
	
	internal function get height():Number
	{
		return com.doswf.alchemy.Memory.getFloat(transformPointer2+12);
		//transformData2.position = transformPointer2 + 12;
		//return transformData2.readFloat();
	}
	
	internal function set height(value:Number):void
	{
		com.doswf.alchemy.Memory.setFloat(value,transformPointer2 + 12);
		//transformData2.position = transformPointer2 + 12;
		//transformData2.writeFloat(value);
	}
	
	internal function get left():Number
	{
		return com.doswf.alchemy.Memory.getFloat(transformPointer2+16);
		//transformData2.position = transformPointer2 + 16;
		//return transformData2.readFloat();
	}
	
	internal function set left(value:Number):void
	{
		com.doswf.alchemy.Memory.setFloat(value,transformPointer2 +16);
		//transformData2.position = transformPointer2 + 16;
		//transformData2.writeFloat(value);
	}
	
	internal function get top():Number
	{
		return com.doswf.alchemy.Memory.getFloat(transformPointer2+20);
		//transformData2.position = transformPointer2 + 20;
		//return transformData2.readFloat();
	}
	
	internal function set top(value:Number):void
	{
		com.doswf.alchemy.Memory.setFloat(value,transformPointer2 +20 );
		//transformData2.position = transformPointer2 + 20;
		//transformData2.writeFloat(value);
	}
}