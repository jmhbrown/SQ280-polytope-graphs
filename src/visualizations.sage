from sage.geometry.polyhedron.parent import Polyhedra
import logging, os
from multiprocessing.dummy import Pool as ThreadPool
from collections import defaultdict
load("visible_graphs.sage")
load("sphere.sage")
load("utilities.sage")

logging.basicConfig(level=logging.INFO)

# Code for visualizing visible graphs.

def show_tachyon_scene(tachyon, **kwargs):
    """
    Allows for adjusting the camera center and resolution of a tachyon scene.

    INPUT::

        - ``tachyon`` -- A Tachyon. Required. A tachyon scene with all relevant objects (planes, lights, etc.).

        Tachyon scene options.

        - ``xres Integer`` -- Optional. (default: 800) X-direction resolution.
        - ``yres Integer`` -- Optional. (default: 800) Y-direction resolution.
        - ``camera_center List,Tuple`` -- Optional. (default: (2,5,2)) Camera location.

    OUTPUT::

        New Tachyon scene, with camera re-positioned.

    EXAMPLES::

	Loading the code:

	    sage: load('projection_vectors.sage')

	Usage:

            sage: tachyon.__class__
            <class 'sage.plot.plot3d.tachyon.Tachyon'>
            sage: new_tachyon = show_tachyon_scene(tachyon, camera_center=[1,1,1])
            sage: new_tachyon.__class__
            <class 'sage.plot.plot3d.tachyon.Tachyon'>
            sage: new_tachyon
            Launched png viewer for <class 'sage.plot.plot3d.tachyon.Tachyon'>

    """

    # Set up the tachyon scene
    xres = parse_kwargs(kwargs, 'xres', 800); yres = parse_kwargs(kwargs, 'yres', 800)
    camera_center = parse_kwargs(kwargs, 'camera_center', (2,5,2))

    new_tachyon = Tachyon(xres=xres,yres=yres, camera_center=camera_center, look_at=(0,0,0), zoom=2)
    new_tachyon._objects = tachyon._objects

    return new_tachyon

def build_tach_repr(polyhedron, **kwargs):
    """
    Builds a tachyon scene representing the visible graph regions.

    INPUT::

        - ``polyhedron`` -- Polyhedron. Required. Polyhedron to represent.
        - ``multithreaded`` -- bool. Optional. Whether to use multithreading.

        Sphere building options.

        - ``seed_sphere`` -- A Polyhedron. Optional. A triangulated sphere to use for graphics.
        - ``build_sphere`` -- bool. Optional. Defaults to false. Whether to build a sphere for graphics.
        - ``n_iterations`` -- Integer. Optional. Defaults to 3. Number of iterations of sphere subdivisions.

        Tachyon options.

        - ``xres`` -- Integer. Optional. (default: 800) X-direction resolution.
        - ``yres`` -- Integer. Optional. (default: 800) Y-direction resolution.
        - ``camera_center`` -- List,Tuple. Optional. (default: (2,5,2) Camera location.

    OUTPUT::

        Tachyon representation of the sphere, colored by visible graphs.


    EXAMPLES::

	Loading the code:

	    sage: load('projection_vectors.sage')

	Usage:

            sage: tachyon = build_tach_repr(polytopes.cube())
            INFO:root: Options: {}
            INFO:root: Building map of surface normals.
            INFO:root: Finding projection graphs. This is often a lengthy procedure.
            INFO:root: Running in single threaded mode!
            DEBUG:root: Computing visible graph for normal # 1 (of 8)
            INFO:root: All done finding projection graphs!
            INFO:root: Found 1 unique graphs from 8 vectors
            INFO:root: Colors for this graphic: [(1.0, 0.0, 0.0)]
            INFO:root: Adding textures to tachyon scene.
            DEBUG:root: 8 vectors with color #ff0000
            INFO:root: Adding triangles to tachyon scene.
            INFO:root: All Done!

        When running in multithreaded mode, it's best to work with polyhedrons defined over RDF^3. Vectors defined over other fields (sometimes?) cause the program to error out.

            sage: tachyon = build_tach_repr(polytopes.dodecahedron(exact=False), multithreaded=True, seed_sphere=load('../output/sphere_1026.sobj'))
            INFO:root: Options: {'seed_sphere': A 3-dimensional polyhedron in RDF^3 defined as the convex hull of 1026 vertices, 'multithreaded': True}
            INFO:root: Building map of surface normals.
            INFO:root: Finding projection graphs. This is often a lengthy procedure.
            INFO:root: Running in multithreaded mode!
            INFO:root: All done finding projection graphs!
            INFO:root: Found 2 unique graphs from 2048 vectors
            INFO:root: Colors for this graphic: [(1.0, 0.0, 0.0), (0.0, 1.0, 1.0)]
            INFO:root: Adding textures to tachyon scene.
            DEBUG:root: 536 vectors with color #00ffff
            DEBUG:root: 1512 vectors with color #ff0000
            INFO:root: Adding triangles to tachyon scene.
            INFO:root: All Done!

    """

    logging.info(" Options: %s" % (kwargs))

    # Multithreaded options.
    multithreaded = parse_kwargs(kwargs, 'multithreaded', False)

    # Build the sphere.
    build_sphere = parse_kwargs(kwargs, 'build_sphere', False)

    if build_sphere:
        logging.info(" Building sphere. This may take a while for large numbers of subdivisions.")
        SP = triangulated_sphere(**kwargs)
        logging.info(" Done building sphere.")
    else:
        SP = parse_kwargs(kwargs, 'seed_sphere', polytopes.octahedron())

    # Set up the tachyon scene
    xres = parse_kwargs(kwargs, 'xres', 800); yres = parse_kwargs(kwargs, 'yres', 800)
    camera_center = parse_kwargs(kwargs, 'camera_center', (2,5,2))

    t = Tachyon(xres=xres,yres=yres, camera_center=camera_center, look_at=(0,0,0), zoom=2)
    t.light((0,0,50), 0.5, (1,1,1))
    t.light((10,0,30), 0.5, (1,1,1))
    t.light((0,10,30), 0.5, (1,1,1))
    t.light((-10,0,30), 0.5, (1,1,1))
    t.light((0,-10,30), 0.5, (1,1,1))
    t.light((0,0,-50), 0.5, (1,1,1))

    t.texture('white', color=(1,1,1))
    t.cylinder((0,0,0), (0,0,1), 50, 'white')


    # Build a list of projection graphs.
    normals = get_normals(SP)
    projection_graphs = defaultdict(lambda: [])

    logging.info(" Finding projection graphs. This is often a lengthy procedure.")
    if multithreaded:
        logging.info(" Running in multithreaded mode!")
        pool = ThreadPool(4)
        results = pool.map(
                lambda v: [get_visible_graph(polyhedron, vector(v)), v],
                normals.values()
                )

        pool.close()
        pool.join()

        # pool.map returns an array. We turn it into a dictionary for later use.
        for graph,vec in results:
            projection_graphs[graph].append(vec)
    else:
        logging.info(" Running in single threaded mode!")
        log_counter = 0
        for vec in normals.values():
            if log_counter % 50 == 0:
                logging.debug(" Computing visible graph for normal # %d (of %d)" % (log_counter + 1, len(normals)))
            log_counter += 1
            graph = get_visible_graph(polyhedron, vector(vec))
            projection_graphs[graph].append(vec)

    logging.info(" All done finding projection graphs!")


    logging.info(" Found %d unique graphs from %d vectors" %( len(projection_graphs.keys()), len(normals)))

    # Get a list of enough colors - one for each unique graph
    # Then build a map between the graphs and tachyon textures
    colors = rainbow(len(projection_graphs), format='rgbtuple')
    logging.info(" Colors for this graphic: %s" % (colors))
    vector_textures = {}

    # Build textures for each color, then populates a map
    # between textures and normals (the projection vectors.)
    logging.info(" Adding textures to tachyon scene.")
    for graph in projection_graphs.keys():
        this_texture_id = str(len(colors))
        this_color = colors.pop()

        t.texture(this_texture_id, opacity=0.95, diffuse=0.7, color=this_color)
        vector_textures[this_texture_id] = projection_graphs[graph]
        logging.debug(" %d vectors with color %s" %(len(vector_textures[this_texture_id]), Color(this_color).html_color()))


    # associate a color with each face then add the corresponding triangle
    # to the tachyon scene.
    logging.info(" Adding triangles to tachyon scene.")
    for face,normal in normals.items():
        verts = map(lambda v: list(v), face.vertices())
        this_texture = next(k for k,v in vector_textures.items() if v.count(normal) )
        t.triangle(verts[0], verts[1], verts[2], this_texture)

    logging.info(" All Done!")
    return t
