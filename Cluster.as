package {
	import flash.display.MovieClip;
	import flash.events.*;
	import flash.geom.*;
	public class Cluster extends DynamicMovie {

		// Constants:
		// Public Properties:
		public var blobs:Vector.<Blob>;
		public var mashable:Boolean;
		public var velocity:Point;// pixels per frame
		public var angularVelocity:Number;// radians per frame

		// Private Properties:

		private var canvas:MovieClip;

		// Initialization:
		public function Cluster(canvas:MovieClip, centre:Point, mashable:Boolean = false) {
			setRegistration();
			this.canvas=canvas;
			this.blobs=new Vector.<Blob>  ;
			this.x=centre.x;
			this.y=centre.y;
			this.mashable=mashable;
			this.velocity = new Point();
			this.colour=Math.random()<0.5?0x000000:0xFFFFFF;//TODO set colours properly somehow
			this.angularVelocity = 1;
			this.addBlob(new Blob(new Point()));
			this.addEventListener(Event.ENTER_FRAME, updatePosition);
		}


		// Public Methods:
		public function addBlob(blob:Blob):void {
			this.setRegistration((this.rp.x*this.weight + blob.x)/(this.weight+1),
								 (this.rp.y*this.weight + blob.y)/(this.weight+1));
			blobs.push(blob);
			this.addChild(blob);
		}

		public function updatePosition(event:Event) {
			this.x2+=this.velocity.x;
			this.y2+=this.velocity.y;
			this.rotation2+=this.angularVelocity;

			// ensure the cluster stays within the bounds of the canvas
			// TODO perhaps when clusters get large, shrink them/grow the canvas
			var clusterBounds:Rectangle=this.getBounds(canvas);
			var canvasBounds:Rectangle=canvas.getBounds(canvas);

			if (clusterBounds.left<canvasBounds.left&&this.velocity.x<0) {
				this.velocity.x*=-1;
			} else if (clusterBounds.right > canvasBounds.right && this.velocity.x > 0) {
				this.velocity.x*=-1;
			}

			if (clusterBounds.top<canvasBounds.top&&this.velocity.y<0) {
				this.velocity.y*=-1;
			} else if (clusterBounds.bottom > canvasBounds.bottom && this.velocity.y > 0) {
				this.velocity.y*=-1;
			}
		}

		public function joinCluster(cluster:Cluster, normal:Point) {
			// add the momentums
			var totalWeight=cluster.weight+this.weight;
			this.velocity.x = (this.velocity.x*this.weight + cluster.velocity.x*cluster.weight)/totalWeight;
			this.velocity.y = (this.velocity.y*this.weight + cluster.velocity.y*cluster.weight)/totalWeight;
			this.angularVelocity = (this.angularVelocity*this.weight + cluster.angularVelocity*cluster.weight)/totalWeight;
			// set the colours
			this.mergeColour(cluster);
			//move all the blobs over
			while (cluster.blobs.length > 0) {
				//trace(cluster.blobs.length);
				var newBlob=cluster.blobs.pop();
				newBlob.centre=this.globalToLocal(cluster.localToGlobal(newBlob.centre));
				this.addBlob(newBlob);
			}
		}

		public function get weight():Number {
			return this.blobs.length;
		}

		public function findCollision(hitCluster:Cluster):Point {
			for (var index1 = 0; index1 < this.blobs.length; index1++) {
				var curBlob:Blob = this.blobs[index1];
				var curBlobGlobal:Point = this.localToGlobal(curBlob.centre);
				for (var index2 = 0; index2 < hitCluster.blobs.length; index2++) {
					var hitBlob:Blob = hitCluster.blobs[index2];
					var hitBlobGlobal:Point = hitCluster.localToGlobal(hitBlob.centre);
					var dist = curBlobGlobal.subtract(hitBlobGlobal).length;
					if (dist<=curBlob.radius+hitBlob.radius) {
						var normal = hitBlobGlobal.subtract(curBlobGlobal);
						normal.normalize(1);
						//trace("Normal of collision: "+normal);
						return normal;
					}
				}
			}
			return new Point();
		}

		public function mergeColour(cluster:Cluster):void {
			var totalWeight=this.weight+cluster.weight;
			var mergePercentage=this.weight/totalWeight;
			//var transformer = this.transform.colorTransform.
			this.colour = this.getColorAverage(this.colour, cluster.colour, mergePercentage);
			cluster.colour=this.colour;
		}

		public function set colour(newColour:uint):void {
			var colourTransform:ColorTransform = new ColorTransform();
			colourTransform.color=newColour;
			this.transform.colorTransform=colourTransform;
		}

		public function get colour():uint {
			return this.transform.colorTransform.color;
		}

		// Protected Methods:

		protected function hexToRGB(hex:uint):Object {
			var r = (hex & 0xFF0000) >> 16;
			var g = (hex & 0xFF00) >> 8;
			var b = (hex & 0xFF);
			return {r:r, g:g, b:b};
		}

		protected function rgbToHex(r, g, b) {
			return r<<16 | g<<8 | b;
		}

		protected function getColorAverage( c1:uint, c2:uint, perc:Number ) {
			
			var rgb1 = hexToRGB(c1);
			var rgb2 = hexToRGB(c2);
			if (perc>1) {
				perc=1;
			}
			if (perc<0) {
				perc=0;
			}
			var r:Number=rgb1.r*perc + rgb2.r*(1-perc);
			var g:Number=rgb1.g*perc + rgb2.g*(1-perc);
			var b:Number=rgb1.b*perc + rgb2.b*(1-perc);
			//trace(c1+"+"+c2+" = "+rgbToHex( r, g, b ));
			return rgbToHex( r, g, b );
		}

	}

}