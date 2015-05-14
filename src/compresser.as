package
{
	import flash.desktop.ClipboardFormats;
	import flash.desktop.NativeDragManager;
	import flash.display.Sprite;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.NativeDragEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import flash.utils.ByteArray;
	/**
	 * 2015.5.13
	 * @author chenpeng
	 * 
	 */	
	[SWF(width="400",height="300",backgroundColor="0x333333")]
	public class compresser extends Sprite
	{
		private var list:Array = [];
		private var curHandleFileIndex:int = 0;
		
		private var txt:TextField;
		
		public function compresser()
		{
			this.addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}
		
		protected function onAddedToStage(event:Event):void
		{
			// TODO Auto-generated method stub
			txt = new TextField();
			this.addChild(txt);
			var tf:TextFormat = new TextFormat();
			tf.size = 24;
			tf.bold = true;
			tf.align = TextFormatAlign.CENTER;
			txt.defaultTextFormat = tf;
			txt.text = "\n\n\nDrap Diles Here";
			txt.selectable = false;
			txt.width = 400;
			txt.height = 300;
			txt.textColor = 0x999999;
			txt.mouseEnabled = true;
			
			this.stage.scaleMode = StageScaleMode.NO_SCALE;
			this.addEventListener(NativeDragEvent.NATIVE_DRAG_ENTER, nativeDragEnterHandler);
			this.addEventListener(NativeDragEvent.NATIVE_DRAG_DROP,nativeDragDropHandler);
		}
		
		private function nativeDragEnterHandler(event:NativeDragEvent):void
		{
			if(event.clipboard.hasFormat(ClipboardFormats.FILE_LIST_FORMAT))
			{  
				NativeDragManager.acceptDragDrop(this);
			}
		}
		
		private function nativeDragDropHandler(event:NativeDragEvent):void
		{
			// TODO Auto-generated method stub
			list = [];
			curHandleFileIndex = 0;
			var arr:Array = event.clipboard.getData(ClipboardFormats.FILE_LIST_FORMAT) as Array;
			for each(var file:File in arr)
			{
				if(file.isDirectory)
				{
					list = list.concat(FileUtil.search(file.nativePath));
				}
				else
				{
					list.push(file);
				}
			}
			handleNextFile();
		}
		
		private function handleNextFile():void
		{
			trace("handleNextFile");
			if(curHandleFileIndex >= this.list.length)
			{
				return;
			}
			var file:File = this.list[curHandleFileIndex++];
			handleFile(file);
		}
		
		private function handleFile(file:File):void
		{
			if(file.extension && file.extension.toLowerCase()!="com")
			{
				compress(file.url);
			}
			else if(file.extension && file.extension.toLowerCase()=="com")
			{
				uncompress(file.url);
			}
		}
		
		private function compress(sourceFilePath:String, outputFilePath:String = null):void
		{
			sourceFilePath = FileUtil.path2Url(sourceFilePath);
			var filePath:String = FileUtil.getDirectory(sourceFilePath);
			var fileName:String = FileUtil.getFileName(sourceFilePath);
			var fileExtention:String = FileUtil.getExtension(sourceFilePath);
			if(null == outputFilePath)
			{
				outputFilePath = filePath + fileName + ".com";
			}
			if(fileExtention == "com")
			{
				return;
			}
			
			var content:String = "";
			var file:File = File.applicationDirectory.resolvePath(sourceFilePath);
			var fs:FileStream = new FileStream();
			try
			{
				fs.open(file, FileMode.READ);
				fs.position = 0;
				var ba:ByteArray = new ByteArray();
				ba.writeUTF(fileExtention);//先把文件扩展名写入
				fs.readBytes(ba, ba.position);
				ba.compress();
				fs.close();
				
				outputFilePath = FileUtil.path2Url(outputFilePath);
				var outputFile:File = File.applicationDirectory.resolvePath(outputFilePath);
				fs.open(outputFile, FileMode.WRITE);
				fs.writeBytes(ba);
				fs.close();
				handleNextFile();
			}
			catch(e:Error)
			{
				fs.close();
				handleNextFile();
				return;
			}
		}
		
		private function uncompress(sourceFilePath:String, outputFilePath:String = null):void
		{
			sourceFilePath = FileUtil.path2Url(sourceFilePath);
			var filePath:String = FileUtil.getDirectory(sourceFilePath);
			var fileName:String = FileUtil.getFileName(sourceFilePath);
			var fileExtention:String = FileUtil.getExtension(sourceFilePath);
			
			if(fileExtention != "com")
			{
				handleNextFile();
				return;
			}
			
			var content:String = "";
			var file:File = File.applicationDirectory.resolvePath(sourceFilePath);
			var fs:FileStream = new FileStream();
			try
			{
				fs.open(file, FileMode.READ);
				fs.position = 0;
				var ba:ByteArray = new ByteArray();
				fs.readBytes(ba);
				fs.close();
				ba.uncompress();
				ba.position = 0;
				var outputExtention:String = ba.readUTF();
				if(null == outputFilePath)
				{
					outputFilePath = filePath + fileName +  "." + outputExtention;//".uncom" +
				}				
				//var str:String = ba.readUTFBytes(ba.length);
				outputFilePath = FileUtil.path2Url(outputFilePath);
				var outputFile:File = File.applicationDirectory.resolvePath(outputFilePath);
				fs.open(outputFile, FileMode.WRITE);
				//fs.writeUTFBytes(str);
				fs.writeBytes(ba, ba.position);
				fs.close();
				handleNextFile();
			}
			catch(e:Error)
			{
				fs.close();
				handleNextFile();
				return;
			}
		}
	}		
}