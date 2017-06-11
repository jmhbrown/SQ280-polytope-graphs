from sage.geometry.polyhedron.parent import Polyhedra
import logging, os
from multiprocessing.dummy import Pool as ThreadPool
from collections import defaultdict
load("visible_graphs.sage")
load("sphere.sage")
load("utilities.sage")

logging.basicConfig(level=logging.DEBUG)

# Code for visualizing visible graphs.

projection_graphs = defaultdict(lambda: [])


def list_to_str(l):
    """
    Converts a list into a space delineated string.

    INPUT:

        - ``l List`` -- List.

    OUTPUT:

    A space-separated string containing the old list items.

    """
    return " ".join(map(lambda x: str(x), l))


def show_tachyon_scene(tachyon, **kwargs):
    """
    Actually shows (saves?) a tachyon scene.

    INPUT:

        - ``tachyon`` -- A Tachyon. Required. A tachyon scene will all relevant objects (planes, lights, etc.).

        Tachyon scene options.

        - ``xres Integer`` -- Optional. (default: 800) X-direction resolution.
        - ``yres Integer`` -- Optional. (default: 800) Y-direction resolution.
        - ``camera_center List,Tuple`` -- Optional. (default: (2,5,2)) Camera location.

    OUTPUT:

        New Tachyon scene, with camera re-positioned.
    """

    # Set up the tachyon scene
    xres = parse_kwargs(kwargs, 'xres', 800); yres = parse_kwargs(kwargs, 'yres', 800)
    camera_center = parse_kwargs(kwargs, 'camera_center', (2,5,2))

    new_tachyon = Tachyon(xres=xres,yres=yres, camera_center=camera_center, look_at=(0,0,0), zoom=2)
    new_tachyon._objects = tachyon._objects
    new_tachyon.show()

    return new_tachyon

def build_tach_repr(polyhedron, **kwargs):
    """
    Builds a tachyon scene representing the visible graph regions.
    INPUT:

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

    OUTPUT:

        Tachyon representation of the sphere, colored by visible graphs.

    EXAMPLES::

        sage: bucky_ball = polytopes.buckyball()
        sage: t = build_tach_repr(bucky_ball, build_sphere=True, sphere_subdivisions=3)
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
