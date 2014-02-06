package com.sss.threed.geometry 
{
import flash.display3D.Context3D;
import flash.display3D.Context3DProgramType;
import flash.display3D.Context3DVertexBufferFormat;
import flash.display3D.IndexBuffer3D;
import flash.display3D.VertexBuffer3D;
import flash.geom.Matrix3D;
import flash.geom.Vector3D;
import flash.utils.Dictionary;
import flash.utils.getQualifiedClassName;

import com.sss.threed.Camera;
import com.sss.threed.Object3D;
import com.sss.threed.Stage3DBase;
import com.sss.threed.Surface;
import com.sss.threed.geometry.IGeometry;
import com.sss.threed.shader.ProgramBase;
import com.sss.util.U;
/**
** @author J. Terry Corbet
** @version 1.0 2014-01-25
*/
public class GeometryBase
	implements IGeometry
{
	private var _span:uint;
	private var _vertexBuffer:VertexBuffer3D;
	private var _indexBuffer:IndexBuffer3D;
	private var _geometrySurfaces:Dictionary;
	private var indexed:Array;

	protected var vertices:Vector.<Number>;
	protected var vdx:uint;
	protected var indices:Vector.<uint>;
	protected var currentSurface:Surface;

	protected var wSpan:uint;
	protected var wBuffer:VertexBuffer3D;
	protected var wVertices:Vector.<Number>;

	public function
	GeometryBase (span:uint)
	{
		_span = span;
		_geometrySurfaces = new Dictionary (false);
		vertices = new Vector.<Number>();
		indices = new Vector.<uint>();
	} // End of Constructor for GeometryBase.

	public function
	dispose()
	:void
	{
		for (var key:String in _geometrySurfaces) {
			var surface:Surface = (_geometrySurfaces[key] as Surface);
			surface.dispose();
			delete _geometrySurfaces[key];
			trace ("Surface", key, "disposed.");
		}
		_geometrySurfaces = null;
		_vertexBuffer = null; wBuffer = null;
		vertices = null; wVertices = null;
		_indexBuffer = null;
		indices = null;
		currentSurface = null;
	} // End of dispose().

	[Inline] public final function get indexBuffer():IndexBuffer3D { return (_indexBuffer); };
	[Inline] public final function get geometrySurfaces():Dictionary { return (_geometrySurfaces); };
	[Inline] public final function get span():uint { return (_span); };
	[Inline] public final function get numVertices():uint { return (vertices.length / _span); };

	public function
	findMinimaMaxima (transform:Matrix3D)
	:Array
	{
		var min:Vector3D = new Vector3D();
		min.x = min.y = min.z = Infinity;
		var max:Vector3D = new Vector3D();
		max.x = max.y = max.z = -Infinity;
		var v:Vector3D = new Vector3D();
		var idx:uint;
		for (idx = 0; idx < vertices.length; ) {
			v.x = vertices[idx++];
			v.y = vertices[idx++];
			v.z = vertices[idx++];
			var vt:Vector3D = v;
			if (vt.x < min.x) {
				min.x = vt.x;
			} else if (vt.x > max.x) {
				max.x = vt.x;
			}
			if (vt.y < min.y) {
				min.y = vt.y;
			} else if (vt.y > max.y) {
				max.y = vt.y;
			}
			if (vt.z < min.z) {
				min.z = vt.z;
			} else if (vt.z > max.z) {
				max.z = vt.z;
			}
			idx += (_span - 3);
		}
		return (new Array (min, max));
	} // End of findMinimaMaxima().

	public function
	addSurface (surface:Surface)
	:void
	{
		_geometrySurfaces[surface.id] = surface;
	} // End of addSurface().

	/* 2014-01-01
	** I am transforming vertex normals on the GPU each frame. An optimization could be
	** implemented wherein the normals would be transformed on the CPU, only when required
	** by checking the object's changedTransform. In my current test pattern, however, almost
	** all objects are animated, so that would, it seems, be counter-productive. Given an appplication
	** like the Idog3D, however, where most objects never change position or orientation, it might
	** be faster, but for such a non-animated application, the speed gain probably would not be
	** observable, and reduced GPU load is not of much interest unless you imagine multiple GPU-centric
	** applications competing concurrently for desktop resources.
	*/
	public function
	activateVertexStreams (context3D:Context3D, programID:String)
	:void
	{
		if (! vertices.length > 0) {
			throw (new Error ("No vertices set."));
		}
		if (_vertexBuffer == null) {
			trace ("Uploading", geometryID, "Vertices:", vertices.length, numVertices);
			_vertexBuffer = context3D.createVertexBuffer (numVertices, _span);
			_vertexBuffer.uploadFromVector (vertices, 0, numVertices);
		}

		// va0 = Position.
		context3D.setVertexBufferAt (0, _vertexBuffer, 0, Context3DVertexBufferFormat.FLOAT_3);
		switch (programID) {
			case (ProgramBase.COLOR_01):
			case (ProgramBase.COLOR_02):
				context3D.setVertexBufferAt (1, null);
				context3D.setVertexBufferAt (2, null);
				break;
			case (ProgramBase.COLOR_11):
				// va1 = Normal.
				context3D.setVertexBufferAt (1, _vertexBuffer, 3, Context3DVertexBufferFormat.FLOAT_3);
				context3D.setVertexBufferAt (2, null);
				break;
			case (ProgramBase.COLOR_12):
				// va1 = Normal.
				context3D.setVertexBufferAt (1, _vertexBuffer, 3, Context3DVertexBufferFormat.FLOAT_3);
				// va2 = RGBA.
				context3D.setVertexBufferAt (2, _vertexBuffer, 6, Context3DVertexBufferFormat.FLOAT_4);
				break;
			case (ProgramBase.TEXTURE_01):
				context3D.setVertexBufferAt (1, null);
				// va12 = UV.
				context3D.setVertexBufferAt (2, _vertexBuffer, 3, Context3DVertexBufferFormat.FLOAT_2);
				break;
			case (ProgramBase.TEXTURE_02):
				context3D.setVertexBufferAt (1, null);
				// va2 = UV.
				context3D.setVertexBufferAt (2, _vertexBuffer, 6, Context3DVertexBufferFormat.FLOAT_2);
				break;
			case (ProgramBase.TEXTURE_11):
			case (ProgramBase.TEXTURE_12):
				// va1 = Normal.
				context3D.setVertexBufferAt (1, _vertexBuffer, 3, Context3DVertexBufferFormat.FLOAT_3);
				// va2 = UV.
				context3D.setVertexBufferAt (2, _vertexBuffer, 6, Context3DVertexBufferFormat.FLOAT_2);
				break;
			case (ProgramBase.TEXTURE_21):
				// va1 = UV.
				context3D.setVertexBufferAt (1, _vertexBuffer, 6, Context3DVertexBufferFormat.FLOAT_2);
				context3D.setVertexBufferAt (2, null);
				break;
			case (ProgramBase.WIRE_1):
				// va1 = Edged Distances.
				context3D.setVertexBufferAt (1, _vertexBuffer, 3, Context3DVertexBufferFormat.FLOAT_3);
				context3D.setVertexBufferAt (2, null);
				break;
		} // End of Switch on ProgramID.

		if (_indexBuffer == null) {
			trace ("Uploading", geometryID, "Indices:", indices.length);
			_indexBuffer = context3D.createIndexBuffer (indices.length);
			_indexBuffer.uploadFromVector (indices, 0, indices.length);
		}
	} // End of activateVertexStreams().

	public function
	get geometryID()
	:String
	{
		var qName:String = getQualifiedClassName (this);
		var idx:int = qName.lastIndexOf ("::");
		idx = ((idx < 0) ? 0 : (idx + 2));
		return (qName.substr (idx));
	} // End of geometryID getter.

	public function
	getSurfaceByID (id:String)
	:Surface
	{
		for each (var surface:Surface in _geometrySurfaces) {
			if (surface.id == id) return (surface);
		}
		return (null);
	}// End of getSurfaceByID().

	public function
	getSurfacePicked (obj:Object3D, x:Number, y:Number, stage3D:Stage3DBase)
	:Surface
	{
		if (U.getDictionaryItemCount (obj.objectSurfaces) == 1) {
			var surface:Surface;
			for each (surface in obj.objectSurfaces) { };
			return (surface);
		}

		var sx:Number = (((x * 2.0) / stage3D.sceneWidth) - 1.0);
		var sy:Number = (((y * 2.0) / stage3D.sceneHeight) - 1.0);
		var lensInverse:Matrix3D = stage3D.projection.clone();
		lensInverse.invert();
		var temp:Vector3D = lensInverse.transformVector (new Vector3D (0.0, 0.0, 0.0, 1.0));
		temp.z = 0.0;
		var rayPos:Vector3D = stage3D.camera.transform.transformVector (temp);
		// trace ("Ray Pos", rayPos);
		temp = lensInverse.transformVector (new Vector3D (sx, -sy, 1.0, 1.0));
		temp.z = 1.0;
		var rayDir:Vector3D = stage3D.camera.transform.transformVector (temp);
		rayDir = rayDir.subtract (rayPos);
		// trace ("Ray Dir", rayDir);

		var transformer:Matrix3D = obj.transform;
		var v0:Vector3D = new Vector3D();
		var v1:Vector3D = new Vector3D();
		var v2:Vector3D = new Vector3D();
		for (var idx:uint = 0; idx < indices.length; ) {
			var jdx:uint = (indices[idx++] * _span);
			v0.x = vertices[jdx++]; v0.y = vertices[jdx++]; v0.z = vertices[jdx++];
			jdx = (indices[idx++] * _span);
			v1.x = vertices[jdx++]; v1.y = vertices[jdx++]; v1.z = vertices[jdx++];
			jdx = (indices[idx++] * _span);
			v2.x = vertices[jdx++]; v2.y = vertices[jdx++]; v2.z = vertices[jdx++];
			v0 = transformer.transformVector (v0);
			v1 = transformer.transformVector (v1);
			v2 = transformer.transformVector (v2);
			if (intersectsTriangle (rayPos, rayDir, v0, v1, v2)) {
				return (getSurfaceByIndex (idx - 3));
			}
		}
		return (null);
	}// End of getSurfacePicked().

	// Möller-Trumbore.
	private function
	intersectsTriangle (org:Vector3D, ray:Vector3D, v0:Vector3D, v1:Vector3D, v2:Vector3D)
	:Boolean
	{
		const epsilon:Number = 0.000001;
		var edge1:Vector3D = v1.subtract (v0);
		var edge2:Vector3D = v2.subtract (v0);
		var pvec:Vector3D = ray.crossProduct (edge2);
		var tvec:Vector3D, qvec:Vector3D;
		var det:Number = edge1.dotProduct (pvec);
		if (det < epsilon) return (false);
		tvec = org.subtract (v0);
		var u:Number = tvec.dotProduct (pvec);
		if ((u < 0.0) || (u > det)) return (false);
		qvec = tvec.crossProduct (edge1);
		var v:Number = ray.dotProduct (qvec);
		if ((v < 0.0) || ((u + v) > det)) return (false);
		return (true);
	} // End of intersectsTriangle().

	/* Use this version for debugging.
	private function
	intersectsTriangle (org:Vector3D, ray:Vector3D, v0:Vector3D, v1:Vector3D, v2:Vector3D, cull:Boolean,
		result:Vector3D)
	:Boolean
	{
		const epsilon:Number = 0.000001;
		var edge1:Vector3D = v1.subtract (v0);
		var edge2:Vector3D = v2.subtract (v0);
		var pvec:Vector3D = ray.crossProduct (edge2);
		var tvec:Vector3D, qvec:Vector3D;
		var det:Number = edge1.dotProduct (pvec);
		var invDet:Number;
		if (cull) {
			if (det < epsilon) return (false);
			tvec = org.subtract (v0);
			result.y = tvec.dotProduct (pvec);
			if ((result.y < 0.0) || (result.y > det)) return (false);
			qvec = tvec.crossProduct (edge1);
			result.z = ray.dotProduct (qvec);
			if ((result.z < 0.0) || ((result.y + result.z) > det)) return (false);
			invDet = (1.0 / det);
			result.x = edge2.dotProduct (qvec);
			result.x *= invDet;
			result.y *= invDet;
			result.z *= invDet;
		} else {
			if ((det > -epsilon) && (det < epsilon)) return (false);
			invDet = (1.0 / det);
			tvec = org.subtract (v0);
			result.y = (tvec.dotProduct (pvec) * invDet);
			if ((result.y < 0.0) || (result.y > 1.0)) return (false);
			qvec = tvec.crossProduct (edge1);
			result.z = (ray.dotProduct (qvec) * invDet);
			if ((result.z < 0.0) || ((result.y + result.z) > 1.0)) return (false);
			result.x = (edge2.dotProduct (qvec) * invDet);
		}
		result.w = det;
		return (true);
	} // End of intersectsTriangle().
	*/

	private function
	getSurfaceByIndex (idx:uint)
	:Surface
	{
		if (indexed == null) index();
		var prev:Object = null;
		for each (var obj:Object in indexed) {
			if (obj.start > idx) return (getSurfaceByID (prev.id));
			prev = obj;
		}
		return (getSurfaceByID (prev.id));
	} // End of getSurfaceByIndex().

	private function
	index()
	:void
	{
		indexed = [];
		for each (var surface:Surface in _geometrySurfaces) {
			indexed.push ({ id : surface.id, start : surface.offset });
		}
		indexed.sortOn ("start", Array.NUMERIC);
		for each (var obj:Object in indexed) {
			trace (obj.id, obj.start);
		}
	} // End of index().

	public function
	wire (context3D:Context3D)
	:void
	{
		wSpan = _span;
		wVertices = vertices;
		wBuffer = _vertexBuffer;

		_span = 6;
		vertices = generateVertices (wSpan);
		_vertexBuffer = context3D.createVertexBuffer (numVertices, _span);
		_vertexBuffer.uploadFromVector (vertices, 0, numVertices);
		return;

		function
		generateVertices (span:uint)
		:Vector.<Number>
		{
			var tv:Vector.<Number> = new Vector.<Number>();
			var idx:uint;
			for (idx = 0; idx < indices.length; ) {
				var jdx:uint = (indices[idx++] * span);
				var v1:Vector3D = new Vector3D (
					vertices[jdx++],
					vertices[jdx++],
					vertices[jdx++]
					);
				jdx = (indices[idx++] * span);
				var v2:Vector3D = new Vector3D (
					vertices[jdx++],
					vertices[jdx++],
					vertices[jdx++]
					);
				jdx = (indices[idx++] * span);
				var v3:Vector3D = new Vector3D (
					vertices[jdx++],
					vertices[jdx++],
					vertices[jdx++]
					);

				tv.push (v1.x); tv.push (v1.y); tv.push (v1.z);
				tv.push (vertexToEdgeDistance (v1, v2, v3)); tv.push (0.0); tv.push (0.0);
				tv.push (v2.x); tv.push (v2.y); tv.push (v2.z);
				tv.push (0.0); tv.push (vertexToEdgeDistance (v2, v1, v3)); tv.push (0.0);
				tv.push (v3.x); tv.push (v3.y); tv.push (v3.z);
				tv.push (0.0); tv.push (0.0); tv.push (vertexToEdgeDistance (v3, v1, v2));
			}
			// trace ("IL", indices.length / 3);
			// trace (tv.length, "<<<>>>", tv);
			return (tv);

			function vertexToEdgeDistance (v1:Vector3D, v2:Vector3D, v3:Vector3D)
			:Number
			{
				var vA:Vector3D = v2.subtract (v1);
				var vB:Vector3D = v3.subtract (v1);
				var vC:Vector3D = v3.subtract (v2);
				return (vA.crossProduct (vB).length / vC.length);
			} // End of vertexToEdgeDistance().
		} // End of generateVertices().
	} // End of wire().

	public function
	unWire()
	:void
	{
		_span = wSpan;
		vertices = wVertices;
		_vertexBuffer = wBuffer;
	} // End of unWire().

	protected function
	mergeNormals (span:uint, position:uint = 3, reverse:Boolean = false)
	:void
	{
		var normals:Vector.<Number> = calcNormals (span, reverse);
		var tv:Vector.<Number> = vertices.slice (0);
		vertices.length = 0;
		var idx:int = (span - position);
		while (tv.length > 0) {
			vertices.push (tv.shift());
			if (++idx == span) {
				for (var jdx:uint = 0; jdx < 3; ++jdx) {
					vertices.push (normals.shift());
				}
				idx = 0;
			}
		}
		return;

		// Adapted from Minko implementation.
		function
		calcNormals (span:uint, reverse:Boolean)
		:Vector.<Number>
		{
			var numVerts:uint = (vertices.length / span);
			var normals:Vector.<Number> = new Vector.<Number> (3 * numVerts);
			var idx: uint;
			for (idx = 0; idx < (indices.length / 3); ++idx) {
				var i0	: int 		= indices[int(3 * idx)];
				var i1	: int 		= indices[int(3 * idx + 1)];
				var i2	: int 		= indices[int(3 * idx + 2)];

				var ii0	: int 		= (span * i0);
				var ii1	: int		= (span * i1);
				var ii2	: int 		= (span * i2);

				var x0	: Number 	= vertices[ii0];
				var y0	: Number 	= vertices[int(ii0 + 1)];
				var z0	: Number 	= vertices[int(ii0 + 2)];

				var x1	: Number 	= vertices[ii1];
				var y1	: Number 	= vertices[int(ii1 + 1)];
				var z1	: Number 	= vertices[int(ii1 + 2)];

				var x2	: Number 	= vertices[ii2];
				var y2	: Number 	= vertices[int(ii2 + 1)];
				var z2	: Number 	= vertices[int(ii2 + 2)];

				var nx	: Number 	= (y0 - y2) * (z0 - z1) - (z0 - z2) * (y0 - y1);
				var ny	: Number 	= (z0 - z2) * (x0 - x1) - (x0 - x2) * (z0 - z1);
				var nz	: Number 	= (x0 - x2) * (y0 - y1) - (y0 - y2) * (x0 - x1);

				normals[int(i0 * 3)] += nx;
				normals[int(i0 * 3 + 1)] += ny;
				normals[int(i0 * 3 + 2)] += nz;

				normals[int(i1 * 3)] += nx;
				normals[int(i1 * 3 + 1)] += ny;
				normals[int(i1 * 3 + 2)] += nz;

				normals[int(i2 * 3)] += nx;
				normals[int(i2 * 3 + 1)] += ny;
				normals[int(i2 * 3 + 2)] += nz;
			}

			for (idx = 0; idx < numVerts; ++idx) {
				if (reverse) {
					normals[int(idx * 3)] = -normals[int(idx * 3)];
					normals[int(idx * 3 + 1)] = -normals[int(idx * 3 + 1)];
					normals[int(idx * 3 + 2)] = -normals[int(idx * 3 + 2)];
				}
				var x	: Number = normals[int(idx * 3)];
				var y	: Number = normals[int(idx * 3 + 1)];
				var z	: Number = normals[int(idx * 3 + 2)];

				var mag	: Number = Math.sqrt(x * x + y * y + z * z);
				if (mag != 0.) {
					normals[int(idx * 3)] /= mag;
					normals[int(idx * 3 + 1)] /= mag;
					normals[int(idx * 3 + 2)] /= mag;
				}
			}
			return (normals);
		} // End of calcNormals().
	} // End of mergeNormals().

	public function
	toString()
	:String
	{
		return (geometryID + " Num Vertices = " + numVertices + ", Num Triangles = " + (indices.length / 3));
	} // End of toString().

} // End of GeometryBase Class.

} // End of Package Declaration.