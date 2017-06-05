# SQ280-polytope-graphs

Class project for Experimental Mathematics.


## How to use this code.

### Setup

This code is meant to be run with Sage. It uses the standard packages `logging`,`os`,`collections`, and `multiprocessing`, and is known to work on Ubuntu 16.04 with the following software versions:

* Sage 7.6
* Python 2.7 

Besides having Sage installed, I know of no special setup process. *If you have trouble getting this code to work, please let me know!*

### Project Structure

```
SQ280-polytope-graphs/
├── output		// For storing Sage objects
│   └── {sphere_N.sobj}			// A bunch of files - including some pre-generated triangulated spheres.
├── src			// Actual Code
│   ├── projection_vectors.sage		// Code for finding some fundamental vectors associated with a polyhedron.
│   ├── sphere.sage			// Code for generating approximations of spheres.
│   ├── utilities.sage			// Helper functions. Used in other parts of the codebase.
│   ├── visible_graphs.sage		// Code for finding visible graphs.
│   └── visualizations.sage		// Code for making (Tachyon) representations of Visible Graph equivalence classes.
└── workspace		// Experiments and junk code.
```

### Common Tasks

#### Making graphs

Use `get_visible_graph` in `visible_graphs.sage` to generate graphs:

```
sage: get_visible_graph?
Signature:      get_visible_graph(polyhedron, projection_vector)
Docstring:     
   Finds the visible graph associated with a particular vector. INPUT:

      * "polyhedron" -- Polyhedron. Required. Polyhedron whose
        visible graph we want to find.

      * "projection_vector" -- Vector. Required. Vector to project
        along.

   OUTPUT:

      Immutable, canonical version of the visible graph.
Init docstring: x.__init__(...) initializes x; see help(type(x)) for signature
File:           Dynamically generated function. No source code available.
Type:           function
```

#### Visualizing Equivalence Classes

Use `build_tach_repr` in `visualizations.sage` to make the representations. Use `show_tachyon_scene` to change camera angle and resolution.

```
sage: build\_tach\_repr?
Signature:      build\_tach\_repr(polyhedron, **kwargs)
Docstring:     
   Builds a tachyon scene representing the visible graph regions.
   INPUT:

      * "polyhedron" -- Polyhedron. Required. Polyhedron to
        represent.

      * "multithreaded" -- bool. Optional. Whether to use
        multithreading.

      Sphere building options.

      * "seed_sphere" -- A Polyhedron. Optional. A triangulated
        sphere to use for graphics.

      * "build_sphere" -- bool. Optional. Defaults to false. Whether
        to build a sphere for graphics.

      * "n_iterations" -- Integer. Optional. Defaults to 3. Number
        of iterations of sphere subdivisions.

      Tachyon options.

      * "xres" -- Integer. Optional. (default: 800) X-direction
        resolution.

      * "yres" -- Integer. Optional. (default: 800) Y-direction
        resolution.

      * "camera_center" -- List,Tuple. Optional. (default: (2,5,2)
        Camera location.

   OUTPUT:

      Tachyon representation of the sphere, colored by visible graphs.

   EXAMPLES:

      sage: bucky_ball = polytopes.buckyball()
      sage: t = build_tach_repr(bucky_ball, build_sphere=True, sphere_subdivisions=3)
Init docstring: x.__init__(...) initializes x; see help(type(x)) for signature
File:           ~/.sage/temp/wrex/19557/visualizations.sagehA3Wk2.py
Type:           function
```

#### Generating Sphere Approximations

Either use the `triangulated_sphere` function from `sphere.sage` or pass the parameter `build_sphere=True` to `build_tachyon_repr` in `visualizations.sage`

```
sage: triangulated_sphere?
Signature:      triangulated_sphere(**kwargs)
Docstring:     
   Makes a triangulation of a unit sphere, by repeatedly dividing the
   faces of an octahedron. The final triangulation will have
   8*4^(subdivisions-1) = 2*4^(subdivision) sides.

   INPUT:

      * "seed_sphere" --  A Polyhedron. Optional. Defaults to an
        octahedron. Base polytope to apply iterations to.

      * "n_iterations" --  An Integer. Optional. Number of times to
        divide faces.

      * "multithreaded" -- Bool. Optional. Whether to run in
        multithreaded mode.

      Save Options:

      * "save_poly" --  Bool. Optional. Defaults to False. Whether
        to save the polytope

      * "save_filepath" --  String. Optional. Defaults to
        cwd+'/output'. Directory to save the polytope in.

      * "save_filename" --  String. Optional. Filename used for save
        file.

   OUTPUT:

      A polyhedron corresponding to a Triangulation of the sphere.
Init docstring: x.__init__(...) initializes x; see help(type(x)) for signature
File:           ~/.sage/temp/wrex/19557/sphere.sageRM9SZz.py
Type:           function
```

## Known Issues.

* `triangulated_sphere()` throws errors when run in multithreaded mode with `polytopes.octahedron()` as the `seed_sphere`.
* Crashes for large triangulated spheres. I've never gotten it to complete a run with a 16385-vertex approximation of a sphere.  
* No debug logs in multithreaded mode. This isn't a bug, but it is obnoxious.
* Suspected issues from floating point arithmetic errors when dealing with polytopes with orthogonal sides. (e.g. with cubes.)
