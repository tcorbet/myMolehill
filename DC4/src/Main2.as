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
import com.sss.threed.shader.Color02;
import com.sss.threed.shader.Color11;
import com.sss.threed.shader.Color12;
import com.sss.threed.shader.Texture11;
import com.sss.threed.shader.Texture12;
import com.sss.threed.shader.Texture21;
import com.sss.threed.shader.WireFrame1;
import com.sss.threed.shader.ProgramBase;
/*
** @author J. Terry Corbet
** @version 1.0 2014-03-05
*/
[SWF (backgroundColor="#778877", frameRate="60", width="1000", height="750")]
public final class Main2 extends Stage3DBase 
{
	[Embed (source = "../assets/CubeTex.png")]
	private const CubeTexture:Class;
	[Embed (source = "../assets/TileDAll.jpg")]
	private const SpecCubeTexture:Class;
	[Embed (source = "../assets/TileDAll_Normal_Transformed.png")]
	private const SpecCubeNormalMap:Class;
	[Embed (source = "../assets/Billiard15.jpg")]
	private const BallTexture:Class;

	// Whether to hold a reference to your 3D Objects, or not, depends upon application logic.
	private var axes:Object3D;

private var T:Number = 0.0;

	public function
	Main2() 
	{
		trace ("Main2 Constructor", "Entered");
		// To override defaults:
		// Always set Scene dimensions and Background color before invoking super().
		stageWidth = 1000; stageHeight = 750;
		backgroundRGBA = new <Number> [
			(((stage.color >> 16) & 0xff) / 0xff),
			(((stage.color >> 8) & 0xff) / 0xff),
			((stage.color & 0xff) / 0xff),
			(0xff / 0xff)];
		// These Projection parameter defaults can similarly be changed.
		near = 1.0; far = 1000.0; fov = 30.0;
		super();
	} // End of Constructor for Main2.

	override protected function
	setupScene (cameraPosition:Vector3D, cameraPOI:Vector3D)
	:void
	{
		// Change initial Camera settings here, if desired.
		super.setupScene (new Vector3D (0.0, 10.0, -60.0), new Vector3D());

		// Always Define/Declare GPU Programs prior to attempted use in an Object3D.
		scene.addProgram (new Color01());
		scene.addProgram (new Color02());
		scene.addProgram (new Color11());
		scene.addProgram (new Color12());
		scene.addProgram (new Texture11());
		scene.addProgram (new Texture12());
		scene.addProgram (new Texture21());
		scene.addProgram (new WireFrame1());

		axes = new Object3D ("Axes-2", GeometryController.AXES, true, 2);
		axes.uniformScale (10.0);
		axes.renderCallBack = axesAnimation;
		axes.pickable = false;
		scene.addObject (axes);

		var pointer:Object3D = new Object3D ("Pointer", GeometryController.POINTER);
		pointer.uniformScale (10.0);
		pointer.translate (2.0, 9.0, 6.0);
		pointer.rotateLocal (45.0, Vector3D.Z_AXIS);
		scene.addObject (pointer);
		// This may take some getting used to.
		// Material is not a property of an Object3D; rather it is a propoerty of that
		// object's Geometry. Since the object's Geometry is manifested by the Scene3D,
		// the changeSurfaceMaterial method would raise a null exception if invoked
		// prior to the object being added to the Scene.
		pointer.changeSurfaceMaterial (Vector.<Number> ([0.36, 0.2, 0.09, 1.0])); // Baker's Chocolate.

		var cube1:Object3D = new Object3D ("RGBCube-1", GeometryController.CUBE);
		cube1.uniformScale (4.0);
		cube1.translate (7.0, 6.0, -4.0);
		cube1.rotateLocal (-15.0, Vector3D.X_AXIS);
		cube1.rotateLocal (25.0, Vector3D.Y_AXIS);
		cube1.rotateLocal (20.0, Vector3D.Z_AXIS);
		cube1.renderCallBack = cube1Animation;
		scene.addObject (cube1);
		cube1.intensity = 2.0;

		var hex:Object3D = new Object3D ("Hex", GeometryController.HEXAMID);
		hex.uniformScale (3.0);
		hex.translate (-4.0, 3.0, 3.0);
		hex.renderCallBack = hexAnimation;
		scene.addObject (hex);
		hex.intensity = 1.2;

		var ball1:Object3D = new Object3D ("Ball-1", GeometryController.BALL, true, 1, 12, 24);
		ball1.uniformScale (5.0);
		ball1.translate (1.0, -3.0, -4.0);
		ball1.renderCallBack = ball1Animation;
		scene.addObject (ball1);
		ball1.specPower = 8;

		var ball2:Object3D = new Object3D ("Ball-2", GeometryController.BALL, true, 2, 18, 36);
		ball2.uniformScale (5.0);
		ball2.translate (5.0, -2.0, 2.0);
		ball2.rotateLocal (5.0, Vector3D.Z_AXIS);
		ball2.renderCallBack = ball2Animation;
		scene.addObject (ball2);
		ball2.specPower = 8;

		var ball3:Object3D = new Object3D ("Ball-3", GeometryController.BALLTEX, true, 18, 36);
		ball3.uniformScale (2.5);
		ball3.rotateLocal (100.0, Vector3D.Y_AXIS);
		ball3.renderCallBack = ball3Animation;
		scene.addObject (ball3);
		ball3.changeSurfaceMaterial (new BallTexture().bitmapData);
		ball3.specPower = 8;

		var cube2:Object3D = new Object3D ("TexturedCube-1", GeometryController.CUBETEX);
		cube2.uniformScale (4.0);
		cube2.translate (-6.0, -4.0, -4.0);
		cube2.rotateLocal (35.0, Vector3D.X_AXIS);
		cube2.rotateLocal (-25.0, Vector3D.Y_AXIS);
		cube2.rotateLocal (-20.0, Vector3D.Z_AXIS);
		cube2.renderCallBack = cube2Animation;
		scene.addObject (cube2);
		cube2.changeSurfaceMaterial (new CubeTexture().bitmapData);
		cube2.antiIntensity = .6;

		var bBoard1:Object3D = new Object3D ("BB-1", GeometryController.BBOARD, false,
			Vector.<Number> ([0.8, 0.7, 0.3, 1.0]));
		bBoard1.uniformScale (1.2);
		bBoard1.translate (0.0, -14.0, 6.0);
		bBoard1.renderCallBack = bb1Animation;
		scene.addObject (bBoard1);
		bBoard1.changeSurfaceMaterial (new Texturizer (context3D, '~ "Hello 3D World"', 200, 75,
			0.1, 2.0, 0xffa501, 0xfffefefe), "face");

		var cube3:Object3D = new Object3D ("WireCube-1", GeometryController.WIRECUBE);
		cube3.uniformScale (6.0);
		cube3.translate (-7.0, 7.0, 4.0);
		cube3.rotateLocal (-15.0, Vector3D.X_AXIS);
		cube3.rotateLocal (25.0, Vector3D.Y_AXIS);
		cube3.rotateLocal (20.0, Vector3D.Z_AXIS);
		cube3.renderCallBack = cube3Animation;
		scene.addObject (cube3);

		var torus:Object3D = new Object3D ("Torus-1", GeometryController.TORUS, false, 32, 28);
		torus.uniformScale (0.4);
		torus.translate (10.0, 12.0, 4.0);
		torus.rotateLocal (-45.0, Vector3D.X_AXIS);
		torus.rotateLocal (45.0, Vector3D.Y_AXIS);
		torus.rotateLocal (-20.0, Vector3D.Z_AXIS);
		torus.renderCallBack = torusAnimation;
		scene.addObject (torus);

		var rCube:Object3D = new Object3D ("RCube", GeometryController.RCUBE, false, 12, 16);
		rCube.uniformScale (0.15);
		rCube.translate (1.0, 3.0, 8.0);
		rCube.rotateLocal (75.0, Vector3D.X_AXIS);
		rCube.rotateLocal (-35.0, Vector3D.Y_AXIS);
		rCube.rotateLocal (-50.0, Vector3D.Z_AXIS);
		rCube.renderCallBack = rCubeAnimation;
		scene.addObject (rCube);

		var con1:Object3D = new Object3D ("Con-1", null);
		con1.uniformScale (0.5);  // Child translation units will be halved.
		con1.translate (-10.0, -1.0, -6.0);
		scene.addObject (con1);
		var torus2:Object3D = new Object3D ("Torus-2", GeometryController.TORUS, false, 28, 24);
		torus2.uniformScale (0.5); // Child scale is compounded by its parent's scale.
		torus2.translate (2.0, 2.0, 5.0);
		torus2.renderCallBack = torusAnimation;
		con1.addChild (torus2, scene);
		// scene.addObject (torus2);
		// And this may even take a little longer to grasp.
		// Here the material cannot be changed until the object has been added to
		// the container because that is where the side-effect of cloning its
		// surfaces takes place.
		torus2.changeSurfaceMaterial (Vector.<Number> ([0.5, 0.7, 0.9, 1.0]));

		var grid:Object3D = new Object3D ("Grid", GeometryController.GRID);
		grid.translate (0.0, -10.0, 0.0);
		grid.pickable = false;
		scene.addObject (grid);
		grid.changeSurfaceMaterial (Vector.<Number> ([1.0, 0.55, 0.0, 1.0]), "fb"); // Dark Orange
		grid.changeSurfaceMaterial (Vector.<Number> ([0.55, 0.27, 0.07, 1.0]), "lr"); // Saddle Brown

		var cube4:Object3D = new Object3D ("TexturedCube-2", GeometryController.CUBETEX);
		cube4.uniformScale (5.0);
		cube4.translate (10.0, -8.0, 5.0);
		cube4.rotateLocal (-35.0, Vector3D.X_AXIS);
		cube4.rotateLocal (25.0, Vector3D.Y_AXIS);
		cube4.rotateLocal (30.0, Vector3D.Z_AXIS);
		cube4.renderCallBack = cube4Animation;
		scene.addObject (cube4);
		cube4.changeSurfaceMaterial ([
			new SpecCubeTexture().bitmapData,
			new SpecCubeNormalMap().bitmapData
			]);
		cube4.changeSurfaceProgram (ProgramBase.TEXTURE_21);
		cube4.intensity = 0.7;
		cube4.antiIntensity = .2;
		cube4.specIntensity = 1.2;
		cube4.specPower = 32;

		trace ("===== Exiting Scene Setup. =====");
	} // End of Overridden setupScene().

	// References to 3D Object Rendering CallBacks, always require global scope.
	private function axesAnimation (obj:Object3D):void { obj.rotateLocal (0.01, Vector3D.Y_AXIS); };
	private function cube1Animation (obj:Object3D):void {
		obj.rotateLocal (0.2, Vector3D.X_AXIS); obj.rotateLocal (0.2, Vector3D.Y_AXIS); obj.rotateLocal (0.2, Vector3D.Z_AXIS);
		};
	private function hexAnimation (obj:Object3D):void { obj.rotateLocal (-0.3, Vector3D.X_AXIS); };
	private function ball1Animation (obj:Object3D):void { obj.rotateLocal (0.2, Vector3D.X_AXIS); };
	private function ball2Animation (obj:Object3D):void { obj.rotateLocal (-0.4, Vector3D.Y_AXIS); };
	private function cube2Animation (obj:Object3D):void {
		obj.rotateLocal (0.03, Vector3D.X_AXIS); obj.rotateLocal (0.02, Vector3D.Y_AXIS); obj.rotateLocal (0.01, Vector3D.Z_AXIS);
		};
	private function bb1Animation (obj:Object3D):void { obj.rotateLocal (-0.3, Vector3D.Y_AXIS); };
	private function cube3Animation (obj:Object3D):void {
		obj.rotateLocal (0.1, Vector3D.X_AXIS); obj.rotateLocal (0.2, Vector3D.Y_AXIS); obj.rotateLocal (0.1, Vector3D.Z_AXIS);
		};
	private function torusAnimation (obj:Object3D):void {
		obj.rotateLocal (0.4, Vector3D.X_AXIS); obj.rotateLocal (0.6, Vector3D.Y_AXIS); obj.rotateLocal (0.8, Vector3D.Z_AXIS);
		};
	private function rCubeAnimation (obj:Object3D):void {
		obj.rotateLocal (-0.6, Vector3D.X_AXIS); obj.rotateLocal (-0.7, Vector3D.Y_AXIS); obj.rotateLocal (-0.8, Vector3D.Z_AXIS);
		};
	private function cube4Animation (obj:Object3D):void {
		obj.rotateLocal (0.2, Vector3D.X_AXIS); obj.rotateLocal (-0.3, Vector3D.Y_AXIS); obj.rotateLocal (-0.1, Vector3D.Z_AXIS);
		};

	private function
	ball3Animation (obj:Object3D)
	:void
	{
		obj.rotateLocal (-1.5, Vector3D.X_AXIS);
	
		T += 0.01;
		if (T > 27.0) T = 0.01;
		const s:Number = 10.0;
		var n:Number = Math.pow (0.5, (0.15 * T));
		obj.moveTo ((s * n * Math.cos (2.0 * T)), (s * n), (s * n * Math.sin (2.0 * T)));
	} // End of ball3Animation().

} // End of Main2 Class.

} // End of Package Declaration.