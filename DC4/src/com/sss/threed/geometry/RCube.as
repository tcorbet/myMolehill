package com.sss.threed.geometry
{
import flash.geom.Vector3D;
import flash.utils.getQualifiedClassName;

import com.sss.threed.Surface;
import com.sss.threed.geometry.GeometryBase;
import com.sss.threed.shader.ProgramBase;
import com.sss.util.U;
/*
** @author J. Terry Corbet
** @version 1.0 2014-01-11
*/
public class RCube extends GeometryBase
{
	public const REAR:uint = 0;
	public const LEFT:uint = 1;
	public const FRONT:uint = 2;
	public const RIGHT:uint = 3;
	public const TOP:uint = 4;
	public const BOTTOM:uint = 5;
	private const HALF_H:Number = 12;
	private const HALF_W:Number = 12;
	private const PROD:Number = 3;

	private var hSegs:uint;
	private var wSegs:uint;
	private var centroids:Vector.<Vector3D>;
	
	public function
	RCube (params:Array)
	{
		super (6);
		constructSurfaces (params);
	} // End of Constructor for RCube.

	private function
	constructSurfaces (params:Array)
	:void
	{
		hSegs = parseInt (params[0]);
		if (hSegs < 8) hSegs = 8;
		wSegs = parseInt (params[1]);
		if (wSegs < 12) wSegs = 12;
		var rad:Number = 4.0;
		var cubeDimension:Number = 20.0;
		centroids = new Vector.<Vector3D>();

		var x:Number, y:Number, z:Number;
		var vSphere:Vector.<Number> = new Vector.<Number>();
		for (var hdx:uint = 0; hdx <= hSegs; ++hdx) {
			var hAngle:Number = (Math.PI * (hdx / hSegs));
			y = (Math.cos (hAngle) * rad);
			var rRad:Number = (Math.sin (hAngle) * rad);
			for (var wdx:uint = 0; wdx <= wSegs; ++wdx) {
				var wAngle:Number = ((Math.PI * 2) * (wdx / wSegs));
				x = (Math.cos (wAngle) * rRad);
				z = (Math.sin (wAngle) * rRad);
				// trace (U.fixedFract (x, 3), U.fixedFract (y, 3), U.fixedFract (z, 3));
				vSphere.push (x, y, z);
			} // End of Longitude Loop.
			// trace ("--------------------------------");
		} // End of Latitude Loop.
		// trace ("# Sphere Vertices", (vSphere.length / 3));

		var vCorners:Vector.<Number> = new Vector.<Number>();
		var iCorners:Vector.<uint> = new Vector.<uint>();
		var cdx:uint;
		for (cdx = 0; cdx < 8; ++cdx) {
			// trace (cdx, "--------------------------------", cdx);
			var ecv:Vector.<Number> = getExplodedSphericalVertices (cdx, vSphere, cubeDimension);
			concatenateTriangulation (vCorners, iCorners, ecv, (hSegs / 2), (wSegs / 4), cdx);
			/*
			for (var idx:uint = 0; idx <= (hSegs / 2); ++idx) {
				var wBuf:String = "";
				for (var jdx:uint = 0; jdx <= (wSegs / 4); ++jdx) {
					var kdx:uint = (((idx * ((wSegs / 4) + 1)) + jdx) * 3);
					x = ecv[kdx++];
					y = ecv[kdx++];
					z = ecv[kdx++];
					wBuf += (
						U.fixedFract (x, 3) + ", " +
						U.fixedFract (y, 3) + ", " +
						U.fixedFract (z, 3) + "  |||  ");
				}
				trace (wBuf);
			}
			trace (cdx, "--------------------------------", cdx);
			*/
		}
		// trace ("# Corner Vertices", (vCorners.length / 3), "# Corner Triangles", (iCorners.length / 3));

		constructBridges (vCorners, iCorners);
		// trace ("# Corner Vertices", (vCorners.length / 3), "# Corner Triangles", (iCorners.length / 3));
		currentSurface = new Surface ("corners", indices.length, ProgramBase.COLOR_11,
			Vector.<Number> ([0.8, 0.2, 0.2, 1.0]));
		geometrySurfaces["corners"] = currentSurface;
		vertices = vCorners.slice();
		indices = iCorners.slice();
		currentSurface.idx = indices.length;
		addSides (vCorners /*, geom, dLight */);
		mergeNormals (3);
	} // End of constructSurfaces().

	public function
	getCentroid (surfaceID:uint)
	:Vector3D
	{
		return (centroids[surfaceID]);
	} // End of getCentroid().

	/* 
	** At first glance it seems redundant to break the geometry up into chunks
	** which will, like Humpty Dumpty, have to be put back together again.
	** Note that this two-step process creates redundant vertices along shared
	** boundaries, but does not create redundant triangles.
	*/
	private function
	getExplodedSphericalVertices (cdx:uint, vSphere:Vector.<Number>, cubeDimension:Number)
	:Vector.<Number>
	{
		var vCorner:Vector.<Number> = new Vector.<Number>();
		var hStride:uint = (hSegs / 2);
		var wStride:uint = (wSegs / 4);
		var hdx:uint;
		var wdx:uint;
		switch (cdx) {
			case (0): // NE-Back.
				hdx = 0;
				wdx = 0;
				break;
			case (1): // SE-Back.
				hdx = hStride;
				wdx = 0;
				break;
			case (2): // NW-Back.
				hdx = 0;
				wdx = wStride;
				break;
			case (3): // SW-Back.
				hdx = hStride;
				wdx = wStride;
				break;
			case (4): // NW-Front.
				hdx = 0;
				wdx = (wStride * 2);
				break;
			case (5): // SW-Front.
				hdx = hStride;
				wdx = (wStride * 2);
				break;
			case (6): // NE-Front.
				hdx = 0;
				wdx = (wStride * 3);
				break;
			case (7): // SE-Front.
				hdx = hStride;
				wdx = (wStride * 3);
				break;
		} // End of Switch on Corner Index.

		for (var idx:uint = hdx; idx <= (hdx + hStride); ++idx) {
			var wBuf:String = "";
			for (var jdx:uint = wdx; jdx <= (wdx + wStride); ++jdx) {
				var kdx:uint = (((idx * (wSegs + 1)) + jdx) * 3);
				var x:Number = vSphere[kdx++];
				var y:Number = vSphere[kdx++];
				var z:Number = vSphere[kdx++];
				vCorner.push (x, y, z);
				wBuf += (
					U.fixedFract (x, 3) + ", " +
					U.fixedFract (y, 3) + ", " +
					U.fixedFract (z, 3) + "  |||  ");
			} // End of Longitudinal Loop.
			// trace (wBuf);
		} // End of Latitudinal Loop.
		// trace (cdx, "--------------------------------", cdx);
		explodeCube (cdx, vCorner, (cubeDimension / 2))
		return (vCorner);
	} // End of getExplodedSphericalVertices().

	private function
	explodeCube (cdx:uint, vCorner:Vector.<Number>, chw:Number)
	:void
	{
		var idx:uint = 0;
		while (idx < vCorner.length) {
			switch (cdx) {
				case (0): // NE-Back.
					vCorner[idx++] += chw;
					vCorner[idx++] += chw;
					vCorner[idx++] += chw;
					break;
				case (1): // SE-Back.
					vCorner[idx++] += chw;
					vCorner[idx++] -= chw;
					vCorner[idx++] += chw;
					break;
				case (2): // NW-Back.
					vCorner[idx++] -= chw;
					vCorner[idx++] += chw;
					vCorner[idx++] += chw;
					break;
				case (3): // SW-Back.
					vCorner[idx++] -= chw;
					vCorner[idx++] -= chw;
					vCorner[idx++] += chw;
					break;
				case (4): // NW-Front.
					vCorner[idx++] -= chw;
					vCorner[idx++] += chw;
					vCorner[idx++] -= chw;
					break;
				case (5): // SW-Front.
					vCorner[idx++] -= chw;
					vCorner[idx++] -= chw;
					vCorner[idx++] -= chw;
					break;
				case (6): // NE-Front.
					vCorner[idx++] += chw;
					vCorner[idx++] += chw;
					vCorner[idx++] -= chw;
					break;
				case (7): // SE-Front.
					vCorner[idx++] += chw;
					vCorner[idx++] -= chw;
					vCorner[idx++] -= chw;
					break;
			} // End of Switch on Corner Index.
		} // End of For Each Vertex.
	} // End of explodeCube().

	private function
	concatenateTriangulation (vCorners:Vector.<Number>, iCorners:Vector.<uint>,
		ecv:Vector.<Number>, hSegs:uint, wSegs:uint, cdx:uint)
	:void
	{
		var wSegsPlus1:uint = (wSegs + 1);
		var iCorner:Vector.<uint> = new Vector.<uint>();
		for (var hdx:uint = 0; hdx <= hSegs; ++hdx) {
			for (var wdx:uint = 0; wdx <= wSegs; ++wdx) {
				if ((hdx == 0) || (wdx == 0)) continue;
				// trace ("HDX", hdx, "WDX", wdx);
				var a:uint = ((wSegsPlus1 * hdx) + wdx);
				var b:uint = ((wSegsPlus1 * hdx) + (wdx - 1));
				var c:uint = ((wSegsPlus1 * (hdx - 1)) + (wdx - 1));
				var d:uint = ((wSegsPlus1 * (hdx - 1)) + wdx);

				if ((cdx % 2) == 0) { // Northern Hemisphere.
					if (hdx == 1) {
						iCorner.push (a, b, c);
						// trace ("ABC", a, b, c);
					} else {
						iCorner.push (a, b, c);
						iCorner.push (a, c, d);
						// trace ("ABC", a, b, c,  "& ACD", a, c, d);
					}
				} else { // Southern Hemisphere.
					if (hdx == hSegs) {
						iCorner.push (a, c, d);
						// trace ("ACD", a, c, d);
					} else {
						iCorner.push (a, b, c);
						iCorner.push (a, c, d);
						// trace ("ABC", a, b, c,  "& ACD", a, c, d);
					}
				}	
			} // End of Longitude Loop.
		} // End of Latitude Loop.
		// trace ("ECV Length", ecv.length, "ICorner Length", iCorner.length);

		var offset:uint = (vCorners.length / 3);
		// trace ("Offset", offset);
		iCorner.forEach (
			function (item:uint, index:int, vector:Vector.<uint>)
			:void
			{
				vector[index] = (item + offset);
			} // End of anonymous closure.
		);

		for each (var nVal:Number in ecv) vCorners.push (nVal);
		// trace ("VCorners Length", vCorners.length);
		for each (var uVal:uint in iCorner) iCorners.push (uVal);
		// trace ("ICorners Length", iCorners.length);
	} // End of concatenateTriangulation().

	private function
	constructBridges (vCorners:Vector.<Number>, iCorners:Vector.<uint>)
	:void
	{			
		var idx:uint, jdx:uint, kdx:uint, ldx:uint;
		var x:Number, y:Number, z:Number;
		var fromCV:Vector.<Number>, toCV:Vector.<Number>;
		var fromOffset:uint, toOffset:uint;
		var cStride:uint = (((hSegs / 2) + 1) * ((wSegs / 4) + 1) * 3);
		var indexes:Array;
		var a:uint, b:uint, c:uint, d:uint;

		// trace ("North - South");
		idx = 0;
		while (idx < 8) {
			fromOffset = (idx * cStride);
			fromCV = getExplodedCornerVertices (idx++, vCorners, cStride);
			toOffset = (idx * cStride);
			toCV = getExplodedCornerVertices (idx++, vCorners, cStride);
			indexes = [];
			for (jdx = 0; jdx <= (wSegs / 4); ++jdx) {
				kdx = ((((hSegs / 2) * ((wSegs / 4) + 1)) + jdx) * 3);
				x = fromCV[kdx++];
				y = fromCV[kdx++];
				z = fromCV[kdx++];
				kdx -= 3;
				// trace ("From:", U.fixedFract (x, 3), U.fixedFract (y, 3), U.fixedFract (z, 3), "=>", (kdx / 3));
				indexes.push ((fromOffset + kdx) / 3);
				kdx = (jdx * 3);
				x = toCV[kdx++];
				y = toCV[kdx++];
				z = toCV[kdx++];
				kdx -= 3;
				// trace ("  To:", U.fixedFract (x, 3), U.fixedFract (y, 3), U.fixedFract (z, 3), "=>", (kdx / 3));
				indexes.push ((toOffset + kdx) / 3);
			}
			for (ldx = 2; ldx <= (indexes.length - 1); ldx += 2) {
				iCorners.push (indexes[(ldx - 2)], indexes[(ldx + 0)], indexes[(ldx + 1)]); // a-c-d.
				iCorners.push (indexes[(ldx - 2)], indexes[(ldx + 1)], indexes[(ldx - 1)]); // a-d-b.
				// trace ("1st", indexes[(ldx - 2)], indexes[(ldx + 0)], indexes[(ldx + 1)]);
				// trace ("2nd", indexes[(ldx - 2)], indexes[(ldx + 1)], indexes[(ldx - 1)]);
			}
		}

		// trace ("North");
		idx = 0;
		while (idx < 7) {
			fromOffset = (idx * cStride);
			fromCV = getExplodedCornerVertices (idx++, vCorners, cStride);
			kdx = ++idx;
			if (kdx > 7) kdx = 0;
			toOffset = (kdx * cStride);
			toCV = getExplodedCornerVertices (kdx, vCorners, cStride);
			indexes = [];
			for (jdx = 0; jdx <= (hSegs / 2); ++jdx) {
				kdx = (((((wSegs / 4) + 1) * (jdx + 1)) - 1) * 3);
				x = fromCV[kdx++];
				y = fromCV[kdx++];
				z = fromCV[kdx++];
				kdx -= 3;
				// trace ("From:", U.fixedFract (x, 3), U.fixedFract (y, 3), U.fixedFract (z, 3), "=>", (kdx / 3));
				indexes.push ((fromOffset + kdx) / 3);
				kdx = ((((wSegs / 4) + 1) * jdx) * 3);
				x = toCV[kdx++];
				y = toCV[kdx++];
				z = toCV[kdx++];
				kdx -= 3;
				// trace ("  To:", U.fixedFract (x, 3), U.fixedFract (y, 3), U.fixedFract (z, 3), "=>", (kdx / 3));
				indexes.push ((toOffset + kdx) / 3);
			}
			for (ldx = 2; ldx <= (indexes.length - 1); ldx += 2) {
				iCorners.push (indexes[(ldx - 2)], indexes[(ldx - 1)], indexes[(ldx + 1)]); // a-b-d.
				iCorners.push (indexes[(ldx - 2)], indexes[(ldx + 1)], indexes[(ldx + 0)]); // a-d-c.
				// trace ("1st", indexes[(ldx - 2)], indexes[(ldx + 0)], indexes[(ldx + 1)]);
				// trace ("2nd", indexes[(ldx - 2)], indexes[(ldx + 1)], indexes[(ldx - 1)]);
			}
		}

		// trace ("South");
		idx = 1;
		while (idx < 8) {
			fromOffset = (idx * cStride);
			fromCV = getExplodedCornerVertices (idx++, vCorners, cStride);
			kdx = ++idx;
			if (kdx > 8) kdx = 1;
			toOffset = (kdx * cStride);
			toCV = getExplodedCornerVertices (kdx, vCorners, cStride);
			indexes = [];
			for (jdx = 0; jdx <= (hSegs / 2); ++jdx) {
				kdx = (((((wSegs / 4) + 1) * (jdx + 1)) - 1) * 3);
				x = fromCV[kdx++];
				y = fromCV[kdx++];
				z = fromCV[kdx++];
				kdx -= 3;
				// trace ("From:", U.fixedFract (x, 3), U.fixedFract (y, 3), U.fixedFract (z, 3), "=>", (kdx / 3));
				indexes.push ((fromOffset + kdx) / 3);
				kdx = ((((wSegs / 4) + 1) * jdx) * 3);
				x = toCV[kdx++];
				y = toCV[kdx++];
				z = toCV[kdx++];
				kdx -= 3;
				// trace ("  To:", U.fixedFract (x, 3), U.fixedFract (y, 3), U.fixedFract (z, 3), "=>", (kdx / 3));
				indexes.push ((toOffset + kdx) / 3);
			}
			for (ldx = 2; ldx <= (indexes.length - 1); ldx += 2) {
				iCorners.push (indexes[(ldx - 2)], indexes[(ldx - 1)], indexes[(ldx + 1)]); // a-b-d.
				iCorners.push (indexes[(ldx - 2)], indexes[(ldx + 1)], indexes[(ldx + 0)]); // a-d-c.
				// trace ("1st", indexes[(ldx - 2)], indexes[(ldx + 0)], indexes[(ldx + 1)]);
				// trace ("2nd", indexes[(ldx - 2)], indexes[(ldx + 1)], indexes[(ldx - 1)]);
			}
		}
	} // End of constructBridge().

	private function
	getExplodedCornerVertices (cdx:uint, vCorners:Vector.<Number>, cStride:uint)
	:Vector.<Number>
	{
		// trace ("VCorners Length", vCorners.length, "CStride", cStride, "Start", (cStride * cdx), "Stop", ((cdx + 1) * cStride));
		var vCorner:Vector.<Number> = vCorners.slice ((cdx * cStride), ((cdx + 1) * cStride));

		for (var idx:uint = 0; idx <= (hSegs / 2); ++idx) {
			var wBuf:String = "";
			for (var jdx:uint = 0; jdx <= (wSegs / 4); ++jdx) {
				var kdx:uint = (((idx * ((wSegs / 4) + 1)) + jdx) * 3);
				var x:Number = vCorner[kdx++];
				var y:Number = vCorner[kdx++];
				var z:Number = vCorner[kdx++];
				wBuf += (
					U.fixedFract (x, 3) + ", " +
					U.fixedFract (y, 3) + ", " +
					U.fixedFract (z, 3) + "  |||  ");
			}
			// trace (wBuf);
		}
		// trace (cdx, "--------------------------------", cdx);
		return (vCorner);
	} // End of getExplodedCornerVertices().

	private function
	addSides (vCorners:Vector.<Number> /*, geom:Geometry, dLight:DirectionalLight */)
	:void
	{
		var cStride:uint = (((hSegs / 2) + 1) * ((wSegs / 4) + 1) * 3);
		var cv0:Vector.<Number> = getExplodedCornerVertices (0, vCorners, cStride);
		var cv1:Vector.<Number> = getExplodedCornerVertices (1, vCorners, cStride);
		var cv2:Vector.<Number> = getExplodedCornerVertices (2, vCorners, cStride);
		var cv3:Vector.<Number> = getExplodedCornerVertices (3, vCorners, cStride);
		var cv4:Vector.<Number> = getExplodedCornerVertices (4, vCorners, cStride);
		var cv5:Vector.<Number> = getExplodedCornerVertices (5, vCorners, cStride);
		var cv6:Vector.<Number> = getExplodedCornerVertices (6, vCorners, cStride);
		var cv7:Vector.<Number> = getExplodedCornerVertices (7, vCorners, cStride);
		var adx:uint, bdx:uint, cdx:uint, ddx:uint, kdx:uint;

		var vSides:Vector.<Number> = new Vector.<Number>();
		var iSides:Vector.<uint> = new Vector.<uint>();
		var centroid:Vector3D;

		adx = (((((hSegs / 2) + 1) * ((wSegs / 4) + 1)) - 1) * 3);
		bdx = (((hSegs / 2) * ((wSegs / 4) + 1)) * 3);
		cdx = 0;
		ddx = ((wSegs / 4) * 3);
		// trace (adx, bdx, cdx, ddx);

		// Rear Face; X-Y.
		vSides.push (cv0[(kdx = adx)]);
		vSides.push (cv0[++kdx]);
		vSides.push (cv0[++kdx]);
		vSides.push (cv2[(kdx = bdx)]);
		vSides.push (cv2[++kdx]);
		vSides.push (cv2[++kdx]);
		vSides.push (cv3[(kdx = cdx)]);
		vSides.push (cv3[++kdx]);
		vSides.push (cv3[++kdx]);
		vSides.push (cv1[(kdx = ddx)]);
		vSides.push (cv1[++kdx]);
		vSides.push (cv1[++kdx]);
		iSides.push (0, 1, 2);
		iSides.push (0, 2, 3);
		centroid = calcCentroid (REAR, vSides, 0, 1, 3, 2);
		centroid.x += HALF_W;
		centroid.y -= HALF_H;
		centroid.z += PROD;
		// trace ("Centroid", centroid);
		centroids.push (centroid);

		// Left Face; Y-Z.
		vSides.push (cv2[(kdx = adx)]);
		vSides.push (cv2[++kdx]);
		vSides.push (cv2[++kdx]);
		vSides.push (cv4[(kdx = bdx)]);
		vSides.push (cv4[++kdx]);
		vSides.push (cv4[++kdx]);
		vSides.push (cv5[(kdx = cdx)]);
		vSides.push (cv5[++kdx]);
		vSides.push (cv5[++kdx]);
		vSides.push (cv3[(kdx = ddx)]);
		vSides.push (cv3[++kdx]);
		vSides.push (cv3[++kdx]);
		iSides.push (4, 5, 6);
		iSides.push (4, 6, 7);
		centroid = calcCentroid (LEFT, vSides, 4, 5, 7, 6);
		centroid.x -= PROD;
		centroid.y -= HALF_H;
		centroid.z += HALF_W;
		// trace ("Centroid", centroid);
		centroids.push (centroid);

		// Front Face; X-Y.
		vSides.push (cv4[(kdx = adx)]);
		vSides.push (cv4[++kdx]);
		vSides.push (cv4[++kdx]);
		vSides.push (cv6[(kdx = bdx)]);
		vSides.push (cv6[++kdx]);
		vSides.push (cv6[++kdx]);
		vSides.push (cv7[(kdx = cdx)]);
		vSides.push (cv7[++kdx]);
		vSides.push (cv7[++kdx]);
		vSides.push (cv5[(kdx = ddx)]);
		vSides.push (cv5[++kdx]);
		vSides.push (cv5[++kdx]);
		iSides.push (8, 9, 10);
		iSides.push (8, 10, 11);
		centroid = calcCentroid (FRONT, vSides, 8, 9, 11, 10);
		centroid.x -= HALF_W;
		centroid.y -= HALF_H;
		centroid.z -= PROD;
		// trace ("Centroid", centroid);
		centroids.push (centroid);

		// Right Face; Y-Z.
		vSides.push (cv6[(kdx = adx)]);
		vSides.push (cv6[++kdx]);
		vSides.push (cv6[++kdx]);
		vSides.push (cv0[(kdx = bdx)]);
		vSides.push (cv0[++kdx]);
		vSides.push (cv0[++kdx]);
		vSides.push (cv1[(kdx = cdx)]);
		vSides.push (cv1[++kdx]);
		vSides.push (cv1[++kdx]);
		vSides.push (cv7[(kdx = ddx)]);
		vSides.push (cv7[++kdx]);
		vSides.push (cv7[++kdx]);
		iSides.push (12, 13, 14);
		iSides.push (12, 14, 15);
		centroid = calcCentroid (RIGHT, vSides, 12, 13, 15, 14);
		centroid.x += PROD;
		centroid.y -= HALF_H;
		centroid.z -= HALF_W;
		// trace ("Centroid", centroid);
		centroids.push (centroid);

		// Top Face; X-Z.
		adx = bdx = cdx = ddx = 0;
		vSides.push (cv0[(kdx = adx)]);
		vSides.push (cv0[++kdx]);
		vSides.push (cv0[++kdx]);
		vSides.push (cv2[(kdx = bdx)]);
		vSides.push (cv2[++kdx]);
		vSides.push (cv2[++kdx]);
		vSides.push (cv4[(kdx = cdx)]);
		vSides.push (cv4[++kdx]);
		vSides.push (cv4[++kdx]);
		vSides.push (cv6[(kdx = ddx)]);
		vSides.push (cv6[++kdx]);
		vSides.push (cv6[++kdx]);
		iSides.push (16, 19, 18);
		iSides.push (16, 18, 17);
		centroid = calcCentroid (TOP, vSides, 17, 16, 18, 19);
		centroid.x -= HALF_H;
		centroid.y += PROD;
		centroid.z -= HALF_W;
		// trace ("Centroid", centroid);
		centroids.push (centroid);

		adx = bdx = cdx = ddx = (((((hSegs / 2) + 1) * ((wSegs / 4) + 1)) - 1) * 3);
		// trace (adx, bdx, cdx, ddx);
		// Bottom Face; X-Z.
		vSides.push (cv1[(kdx = adx)]);
		vSides.push (cv1[++kdx]);
		vSides.push (cv1[++kdx]);
		vSides.push (cv3[(kdx = bdx)]);
		vSides.push (cv3[++kdx]);
		vSides.push (cv3[++kdx]);
		vSides.push (cv5[(kdx = cdx)]);
		vSides.push (cv5[++kdx]);
		vSides.push (cv5[++kdx]);
		vSides.push (cv7[(kdx = ddx)]);
		vSides.push (cv7[++kdx]);
		vSides.push (cv7[++kdx]);
		iSides.push (20, 21, 22);
		iSides.push (20, 22, 23);
		centroid = calcCentroid (BOTTOM, vSides, 20, 21, 23, 22);
		centroid.x -= HALF_H;
		centroid.y -= PROD;
		centroid.z += HALF_W;
		// trace ("Centroid", centroid);
		centroids.push (centroid);

		currentSurface = new Surface ("sides", indices.length, ProgramBase.COLOR_11,
			Vector.<Number> ([0.7, 0.7, 0.1, 1.0]));
		currentSurface.idx = iSides.length;
		geometrySurfaces["sides"] = currentSurface;
		var idx:uint = (vertices.length / 3);
		vertices = vertices.concat (vSides.slice());
		for each (var jdx:uint in iSides) {
			indices.push (idx + jdx);
		}
	} // End of addSides().

	private function
	calcCentroid (surfaceID:uint, vSides:Vector.<Number>, a:uint, b:uint, c:uint, d:uint)
	:Vector3D
	{
		var centroid:Vector3D = new Vector3D();
		var axis:uint = whichAxis (vSides, a, b, c, d);
		/*
		trace (
			U.fixedFract (vSides[(a * 3)], 3),
			U.fixedFract (vSides[((a * 3) + 1)], 3),
			U.fixedFract (vSides[((a * 3) + 2)], 3));
		trace (
			U.fixedFract (vSides[(b * 3)], 3),
			U.fixedFract (vSides[((b * 3) + 1)], 3),
			U.fixedFract (vSides[((b * 3) + 2)], 3));
		trace (
			U.fixedFract (vSides[(c * 3)], 3),
			U.fixedFract (vSides[((c * 3) + 1)], 3),
			U.fixedFract (vSides[((c * 3) + 2)], 3));
		trace (
			U.fixedFract (vSides[(d * 3)], 3),
			U.fixedFract (vSides[((d * 3) + 1)], 3),
			U.fixedFract (vSides[((d * 3) + 2)], 3));
		trace ("Surface Axis", axis);
		*/
		var half:Number;
		switch (/* axis */ surfaceID) {
			case (/* 0 */ LEFT): // X.
			case (RIGHT):
				centroid.x = vSides[(a * 3)];
				half = vSides[((a * 3) + 1)];
				half -= ((half - vSides[((c * 3) + 1)]) / 2);
				centroid.y = half;
				half = vSides[((a * 3) + 2)];
				half += ((vSides[((b * 3) + 2)] - half) / 2);
				centroid.z = half;
				break;
			case (/* 1 */ TOP): // Y.
			case (BOTTOM):
				half = vSides[(a * 3)];
				half += ((vSides[(b * 3)] - half) / 2);
				centroid.x = half;
				centroid.y = vSides[((a * 3) + 1)];
				half = vSides[((a * 3) + 2)];
				half += ((vSides[((c * 3) + 2)] - half) / 2);
				centroid.z = half;
				break;
			case (/* 2 */ FRONT): // Z.
			case (REAR):
				half = vSides[(a * 3)];
				half += ((vSides[(b * 3)] - half) / 2);
				centroid.x = half;
				half = vSides[((a * 3) + 1)];
				half -= ((half - vSides[((c * 3) + 1)]) / 2);
				centroid.y = half;
				centroid.z = vSides[((a * 3) + 2)];
				break;
		} // End of Switch on Which Surface.
		return (centroid);
	} // End of calcCentroid().

	private function
	whichAxis (vSides:Vector.<Number>, a:uint, b:uint, c:uint, d:uint)
	:uint
	{
		var adx:uint = (a * 3);
		var bdx:uint = (b * 3);
		var cdx:uint = (c * 3);
		var ddx:uint = (d * 3);
		if (vSides[adx] == vSides[bdx] &&
			vSides[adx] == vSides[cdx] &&
			vSides[adx] == vSides[ddx]) {
			return (0); // X.
		}
		++adx; ++bdx; ++cdx; ++ddx;
		if (vSides[adx] == vSides[bdx] &&
			vSides[adx] == vSides[cdx] &&
			vSides[adx] == vSides[ddx]) {
			return (1); // Y.
		}
		return (2); // Z.
	} // End of whichAxis().

} // End of RCube Class.

} // End of Package Declaration.