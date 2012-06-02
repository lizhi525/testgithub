package  
{
	import com.adobe.utils.AGALMiniAssembler;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.display.Stage3D;
	import flash.display.StageAlign;
	import flash.display.StageQuality;
	import flash.display.StageScaleMode;
	import flash.display3D.Context3D;
	import flash.display3D.Context3DBlendFactor;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.Context3DRenderMode;
	import flash.display3D.Context3DTextureFormat;
	import flash.display3D.Program3D;
	import flash.display3D.textures.Texture;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Matrix3D;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import net.game_develop.animation.utils.Stats;
	/**
	 * ...
	 * @author lizhi
	 */
	
	[SWF(framerate=60,width=800,height=400)]
	public class Stage3dView extends Sprite
	{
		internal var stage3D:Stage3D;
		internal var w:Number;
		internal var h:Number;
		internal var context3D:Context3D;
		internal var camera:Matrix3D;
		private var maxChildOnce:int = 65535 / 4;
		private var renders:Array = [];
		private var tf:TextField;
		public function Stage3dView() 
		{
			addEventListener(Event.ADDED_TO_STAGE, onAdded);
			addChild(new Stats);
			tf = new TextField;
			addChild(tf);
			tf.autoSize = TextFieldAutoSize.LEFT;
			tf.x = 100;
			tf.defaultTextFormat = new TextFormat(null, 35);
			tf.background = true;
			tf.backgroundColor = 0xffffff;
			
			tf.text = "点击增加动画";
			tf.selectable = tf.mouseWheelEnabled = false;
			tf.addEventListener(MouseEvent.CLICK, tf_click);
		}
		
		public var num:int = 0;
		private function tf_click(e:MouseEvent):void 
		{
			addNum(10000);
		}
		
		private function addNum(num:int):void {
			this.num += num;
			tf.text = "点击增加动画:" + this.num+":"+context3D+w+h;
			while (num-- > 0)
				add();
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
			stage.quality = StageQuality.LOW;
			
			
			stage3D = stage.stage3Ds[0];
			stage3D.addEventListener(Event.CONTEXT3D_CREATE, contextReady);
			stage3D.requestContext3D(Context3DRenderMode.AUTO);
		}
		
		
		private var flag:Boolean = false;
		private function stage_resize(e:Event):void 
		{
			if(context3D){
			w = stage.stageWidth;
			h = stage.stageHeight;
			camera = new Matrix3D;
			camera.appendScale(2 / w, -2 / h, 1);
			camera.appendTranslation(-1, 1, 0);
			context3D.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 0, camera, true);
			context3D.configureBackBuffer(w, h, 0, flag);
			}
			trace("resize");
		}
		
		private function contextReady(pEvent:Event):void
		{
			[Embed(source="orbz_002.png")]
			var bc:Class;
			var bmd:BitmapData = Bitmap(new bc).bitmapData;
			addEventListener(Event.ENTER_FRAME, enterFrame);
			context3D = stage3D.context3D;
			stage_resize(null);
			
			stage.addEventListener(Event.RESIZE, stage_resize);
			var texture:Texture = context3D.createTexture(bmd.width, bmd.height, Context3DTextureFormat.BGRA, true);
			texture.uploadFromBitmapData(bmd);
			context3D.setTextureAt(0, texture);
			
			var vertexAssembler:AGALMiniAssembler = new AGALMiniAssembler();
			//vertexAssembler.assemble(Context3DProgramType.VERTEX, "m44 op,va0,vc0\n" + "mov v0,va1");
			vertexAssembler.assemble(Context3DProgramType.VERTEX, 
																"cos vt0.x,va1.z\n" +
																"sin vt0.y ,va1.z\n" +
																
																"mul vt0.xy ,vt0.xy,va1.xy\n" +
																
																"mul vt1.xyzw,vt0.xyxy,va2.xyyx\n" +
																"sub vt0.z,vt1.x,vt1.y\n" +
																"add vt0.w,vt1.z,vt1.w\n" +
																"add vt0.xy,vt0.zw,va0.xy\n" +
																
																"mov vt0.z, va0.z\n"+
																"mov vt0.w, vc3.w\n"+
																
																"m44 op ,vt0,vc0\n" + 
																"mov v0,va3"
																);
			
			var fragmentAssembler:AGALMiniAssembler = new AGALMiniAssembler();
			context3D.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0, Vector.<Number>([0, 0, 0, 0.000000001]));
			fragmentAssembler.assemble(Context3DProgramType.FRAGMENT, "tex ft0, v0, fs0 <2d,linear,nomip>\nsub ft0.w,ft0.w,fc0.w\nkil ft0.w\nmov oc,ft0");
			//fragmentAssembler.assemble(Context3DProgramType.FRAGMENT, "tex oc, v0, fs0 <2d,linear,nomip>");
			
			var program:Program3D = context3D.createProgram();
			program.upload(vertexAssembler.agalcode, fragmentAssembler.agalcode);
			context3D.setProgram(program);
			
			addEventListener(Event.ENTER_FRAME, enterFrameHandler);
			
			addNum(100);
		}
		
		private function enterFrame(e:Event):void 
		{
			flag = true;
			context3D.configureBackBuffer(w, h, 0, flag);
			removeEventListener(Event.ENTER_FRAME, enterFrame);
		}
		
		private function enterFrameHandler(e:Event):void 
		{
			
			context3D.clear();
			for each(var render:Agal2D in renders) {
				render.enterFrameHandler();
			}
			context3D.present();
		}
		private function add():void
		{
			var render:Agal2D = renders[renders.length - 1];
			if (render == null) {
				render = new Agal2D(this);
				renders.push(render);
			}
			if (render.numChild >= maxChildOnce){
				render = new Agal2D(this);
				renders.push(render);
			}
			render.add();
		}
		/*private function enterFrameHandler(e:Event):void 
		{
			
			context3D.clear();
			for each(var render:Vertex2D in renders) {
				render.enterFrameHandler();
			}
			context3D.present();
		}
		private function add():void
		{
			var render:Vertex2D = renders[renders.length - 1];
			if (render == null) {
				render = new Vertex2D(this);
				renders.push(render);
			}
			if (render.numChild >= maxChildOnce){
				render = new Vertex2D(this);
				renders.push(render);
			}
			render.add();
		}*/
	}

}