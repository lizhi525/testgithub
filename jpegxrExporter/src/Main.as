package 
{
	import com.bit101.components.ComboBox;
	import com.bit101.components.HBox;
	import com.bit101.components.HUISlider;
	import com.bit101.components.Label;
	import com.bit101.components.PushButton;
	import com.bit101.components.VBox;
	import com.bit101.components.Window;
	import flash.display.Bitmap;
	import flash.display.BitmapEncodingColorSpace;
	import flash.display.JPEGXREncoderOptions;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.net.FileFilter;
	import flash.net.FileReference;
	import flash.utils.ByteArray;
	
	/**
	 * ...
	 * @author lizhi
	 */
	public class Main extends Sprite 
	{
		private var loader:Loader;
		private var image:Bitmap;
		private var exportedImage:Bitmap;
		private var file:FileReference;
		private var qslider:HUISlider;
		private var tslider:HUISlider;
		private var list:ComboBox;
		private var window:Window;
		private var info:Label;
		private var sourceSize:int;
		public function Main():void 
		{
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			loader = new Loader;
			image = new Bitmap;
			addChild(image);
			exportedImage = new Bitmap;
			addChild(exportedImage);
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, loader_complete);
			
			window = new Window(this);
			var vbox:VBox = new VBox(window);
			new PushButton(vbox, 0, 0, "open image", open);
			new PushButton(vbox, 0, 0, "export jpegxr", export);
			qslider = new HUISlider(vbox, 0, 0, "quantization",onchange);
			qslider.value = 20;
			tslider = new HUISlider(vbox, 0, 0, "trimFlexBits",onchange);
			var hbox:HBox = new HBox(vbox);
			new Label(hbox, 0, 0, "colorSpace");
			list = new ComboBox(hbox, 0, 0, BitmapEncodingColorSpace.COLORSPACE_AUTO, [BitmapEncodingColorSpace.COLORSPACE_AUTO, BitmapEncodingColorSpace.COLORSPACE_4_2_0, BitmapEncodingColorSpace.COLORSPACE_4_2_2, BitmapEncodingColorSpace.COLORSPACE_4_4_4]);
			list.selectedItem = "auto";
			list.addEventListener(Event.SELECT, onchange);
			info = new Label(vbox, 0, 0, "");
			var label:Label = new Label(vbox, 0, 0, "copyright game-develop.net");
			label.textField.textColor = 0xff0000;
			window.setSize(vbox.width, vbox.height + 30);
			stage_resize(null);
			stage.addEventListener(Event.RESIZE, stage_resize);
			
		}
		
		private function onchange(e:Event):void 
		{
			if (image.bitmapData == null) return;
			var by:ByteArray = image.bitmapData.encode(image.bitmapData.rect, new JPEGXREncoderOptions(qslider.value, list.selectedItem + "", tslider.value));
			var loader:Loader = new Loader;
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, loader_complete2);
			loader.loadBytes(by);
			by.position = 0;
			info.text = Math.round(sourceSize/1024) + " / " + Math.round(by.bytesAvailable/1024)+" kb";
		}
		
		private function loader_complete2(e:Event):void 
		{
			exportedImage.bitmapData = ((e.currentTarget as LoaderInfo).content as Bitmap).bitmapData;
		}
		
		private function stage_resize(e:Event):void 
		{
			window.x = stage.stageWidth - window.width;
			layoutImages();
		}
		
		private function layoutImages():void {
			exportedImage.x = image.width;
			if (exportedImage.x+exportedImage.width>stage.stageWidth) {
				exportedImage.x = stage.stageWidth - exportedImage.width;
			}
			trace(exportedImage.x);
		}
		
		private function export(e:Event):void 
		{
			var file:FileReference = new FileReference;
			var by:ByteArray = image.bitmapData.encode(image.bitmapData.rect, new JPEGXREncoderOptions(qslider.value,list.selectedItem+"",tslider.value));
			file.save(by,this.file.name.replace(/\..*/,".wdp"));
		}
		
		private function open(e:Event):void 
		{
			file = new FileReference;
			file.addEventListener(Event.SELECT, file_select);
			file.addEventListener(Event.COMPLETE, file_complete);
			var imagesFilter:FileFilter = new FileFilter("Images(*.jpg;*.gif;*.png;*.jpg;*.jpeg;*.wdp;*.jxr)", "*.jpg;*.gif;*.png;*.jpg;*.jpeg;*.wdp;*.jxr");
			var allFilter:FileFilter = new FileFilter("all(*.*)","*.*");
			
			file.browse([imagesFilter,allFilter]);
		}
		
		private function loader_complete(e:Event):void 
		{
			image.bitmapData = ((e.currentTarget as LoaderInfo).content as Bitmap).bitmapData;
			exportedImage.bitmapData = image.bitmapData;
			layoutImages();
			onchange(null);
		}
		
		private function file_complete(e:Event):void 
		{
			sourceSize = file.data.bytesAvailable;
			loader.loadBytes(file.data);
		}
		
		private function file_select(e:Event):void 
		{
			file.load();
		}
		
	}
	
}