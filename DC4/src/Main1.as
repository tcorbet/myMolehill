package 
{
import flash.events.Event;
import flash.geom.Vector3D;

import com.sss.threed.GeometryController;
import com.sss.threed.Object3D;
import com.sss.threed.Scene3D;
import com.sss.threed.Stage3DBase;
import com.sss.threed.Texturizer;
import com.sss.threed.shader.Color01;
import com.sss.threed.shader.Color11;
import com.sss.threed.shader.Texture12;
/*
** @author J. Terry Corbet
** @version 1.0 2014-01-20
*/
[SWF (backgroundColor="#778877", frameRate="20", width="1000", height="750")]
public final class Main1 extends Stage3DBase 
{
	private var obj1:Object3D;
	private var obj2:Object3D;
	private var obj3:Object3D;

	public function
	Main1() 
	{
		trace ("Main1 Constructor", "Entered");
		stageWidth = 1000.0; stageHeight = 750.0;
		backgroundRGBA = new <Number> [
			(((stage.color >> 16) & 0xff) / 0xff),
			(((stage.color >> 8) & 0xff) / 0xff),
			((stage.color & 0xff) / 0xff),
			(0xff / 0xff)];
		near = 1.0; far = 1000.0; fov = 30.0;
		super();
	} // End of Constructor for Main1.

	override protected function
	setupScene (cameraPosition:Vector3D, cameraPOI:Vector3D)
	:void
	{
		super.setupScene (new Vector3D (0.0, 10.0, -60.0), cameraPOI);
		// Define/Declare GPU Programs.
		scene.addProgram (new Color01());
		scene.addProgram (new Color11());
		scene.addProgram (new Texture12());
		addEventListener (Event.ENTER_FRAME, testHarness);
	} // End of Overridden setupScene().

	private function
	testHarness (event:Event)
	:void
	{
		var reportFC:Boolean = false;
		if (frameCounter > 1515) return;
		switch (frameCounter % 100) {
			case (5):
				// Create an Object Declaring its Geometry Type.
				obj1 = new Object3D ("ObjOne", GeometryController.AXES, true, 2);
				obj1.uniformScale (10.0);
				obj1.translate (-8.0, 0.0, 0.0);
				trace (obj1);
				reportFC = true;
				break;
			case (10):				
				// Add Object to Scene.
				scene.addObject (obj1);
				trace ("Scene Size", scene.objectCount);
				reportFC = true;
				break;

			case (15):
				// Create an Object Declaring its Geometry Type.
				obj2 = new Object3D ("ObjTwo", GeometryController.AXES, true, 2);
				obj2.uniformScale (10.0);
				obj2.translate (8.0, 0.0, 0.0);
				// Add Object to Scene.
				scene.addObject (obj2);
				trace (obj2);
				trace ("Scene Size", scene.objectCount);
				reportFC = true;
				break;

			case (20):
				// Remove Object from Scene, but don't Dispose.
				scene.removeObject (obj1);
				trace ("Scene Size", scene.objectCount);
				reportFC = true;
				break;

			case (25):
				// Remove Object from Scene, and Dispose.
				scene.removeObject (obj2);
				obj2.dispose();
				obj2 = null;
				trace ("Scene Size", scene.objectCount);
				reportFC = true;
				break;
			case (30):
				// Restore Object to Scene.
				obj1.resetTransform();
				obj1.uniformScale (12.0);
				obj1.translate (-8.0, -8.0, 8.0);
				scene.addObject (obj1);
				trace ("Scene Size", scene.objectCount);
				reportFC = true;
				break;
			case (35):
				// Remove Object from Scene, and Dispose.
				scene.removeObject (obj1);
				obj1.dispose();
				obj1 = null;
				trace ("Scene Size", scene.objectCount);
				// Add Object with Texture to Scene.
				obj3 = new Object3D ("BB", GeometryController.BBOARD, false,
					Vector.<Number> ([0.8, 0.7, 0.3, 1.0]));
				obj3.uniformScale (2.0);
				obj3.translate (0.0, -10.0, 0.0);
				scene.addObject (obj3);
				obj3.changeSurfaceMaterial (new Texturizer (context3D, '~ "Hello 3D World"', 200, 75,
					0.1, 2.0, 0xffa501, 0xfffefefe), "face");
				trace ("Scene Size", scene.objectCount);
				reportFC = true;
				break;
			case (40):
				// Remove Object with Texture from Scene, and Dispose.
				scene.removeObject (obj3);
				obj3.dispose();
				obj3 = null;
				trace ("Scene Size", scene.objectCount);
				reportFC = true;
				break;
		} // End of Switch on Frame Count.
		if (reportFC) trace ("Completed Step", frameCounter);

	} // End of testHarness().

} // End of Main1 Class.

} // End of Package Declaration.