package {
	import flash.display.MovieClip;
	import flash.ui.Mouse;
	import flash.events.*
	import flash.geom.*

	//[SWF(frameRate="31", width="550", height="400", backgroundColor="0x008866")]
	public class Blobber extends MovieClip {
		
		var clusters:Vector.<Cluster>;
		public var canvas:blankCanvas;
		
		public function Blobber() {			
			clusters = new Vector.<Cluster>();
			//this.addCluster();
			this.addEventListener(MouseEvent.MOUSE_DOWN, addCluster);
			this.addEventListener(MouseEvent.MOUSE_UP, fireCluster);
			/*stage.addEventListener(Event.ENTER_FRAME, hitTest);*/
			this.addEventListener(Event.ENTER_FRAME, eachFrame);
		}	
		
		private function fireCluster(event:MouseEvent):void {
			var currentCluster:Cluster = clusters[clusters.length-1];
			var vel:Point = new Point(event.stageX - currentCluster.x, event.stageY - currentCluster.y);
			vel.normalize(5);
			currentCluster.velocity = vel;
		}
		
		private function eachFrame(event:Event):void {
			for(var index1 = 0; index1 < clusters.length; index1++){
				var curCluster = clusters[index1];
				if(!curCluster.mashable) continue;
				for(var index2 = index1+1; index2 < clusters.length; index2++){
					var hitCluster = clusters[index2];
					if(!hitCluster.mashable) continue;
					if(curCluster.hitTestObject(hitCluster)){
						// TODO go through blobs to find if actual collision / collision point
						var normal:Point = curCluster.findCollision(hitCluster);
						if(normal.length > 0){
							curCluster.joinCluster(hitCluster, normal);
							clusters.splice(index2,1); // remove the hit cluster from the list of clusters
						}
					}
				}
			}
		}
		
		private function addCluster(event:MouseEvent):void {
			clusters.push(new Cluster(canvas, new Point(event.stageX, event.stageY), true));
			this.addChild(clusters[clusters.length-1]);
		}
	}
}