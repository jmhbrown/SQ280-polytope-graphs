from string import Template
from sage.geometry.polyhedron.parent import Polyhedra
import logging, os
from multiprocessing.dummy import Pool as ThreadPool 
from collections import defaultdict
load("visible_graphs.sage")
load("sphere.sage")

logging.basicConfig(level=logging.DEBUG)

# Code for visualizing visible graphs.
# TODO:
#   Get the graph associated with each surface normal.
#   From that dictionary figure out a good color scheme.
#   Construct the tachyon representation of the graphics.

graph_colorings = {}
projection_graphs = defaultdict(lambda: [])


def list_to_str(l):
    """
    Converts a list into a space delineated string.
        :param l List:      List.
        :return:            String.
    """
    return " ".join(map(lambda x: str(x), l))


def get_normals(polyhedron):
    """
    Returns a dictionary associating each face with its normal.
        :param polyhedron:      Required. Three dimensional Polyhedron
            :type polyhedron:       Polyhedron
        :return:                Dictionary of normal vectors. Keys are PolyhedronFace, values are Vector
            :rtype:                 Dict
    """
    logging.debug(" Building map of surface normals.")
    normals = {}
    for face in polyhedron.faces(2):
        normals[face] = face.ambient_Hrepresentation()[0]._A

    return normals

def show_tachyon_scene(tachyon, view=(2,5,2), **kargs):
    """
    Actually shows (saves?) a tachyon scene.
        :param tachyon:     Required. A tachyon scene will all relevant objects (planes, lights, etc.).
            :type tachyon:      Tachyon
        :param view:        Optional. Camera position.
            :type view:         Tuple, List.
        :returns:           New Tachyon scene, with camera re-positioned.
            :rtype:             Tachyon
    """

    new_tachyon = Tachyon(xres=800,yres=800, camera_center=view, look_at=(0,0,0))
    new_tachyon._objects = tachyon._objects
    new_tachyon.show()

    return new_tachyon

def build_tach_repr(polyhedron, sphere_subdivisions=3):
    """
    Builds a tachyon scene representing the visible graph regions
        :param  polyhedron:         Required. Polyhedron to represent.
            :type polyhedron:           Polyhedron.
        :param sphere_subdivisions: Optional. Number of iterations of sphere subdivisions.
            :type sphere_subdivisions:  Integer

        :returns:                   Tachyon representation of the sphere, colored by visible graphs.
            :rtype:                 Tachyon.
    """

    multithreaded = False
    logging.debug(" Building sphere. This may take a while for large numbers of subdivisions.")
    SP = triangulated_sphere(polytopes.octahedron(), sphere_subdivisions) 
    logging.debug(" Done building sphere.")

    # Set up the tachyon scene
    t = Tachyon(xres=800,yres=800, camera_center=(2,5,2), look_at=(0,0,0))
    t.light((0,0,10), 1, (1,1,1))
    t.texture('white', color=(1,1,1))
    t.cylinder((0,0,0), (0,0,1), 50, 'white')

    face_colors = []
    
    # Build a list of projection graphs.
    normals = get_normals(SP)
    logging.debug(" Finding projection graphs. Also a lengthy procedure.")
    if multithreaded == True:
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
        log_counter = 0
        for vec in normals.values():
            if log_counter % 10 == 0:
                logging.debug(" Computing visible graph for normal # %d (of %d)" % (log_counter + 1, len(normals)))	
            log_counter += 1
            graph = get_visible_graph(polyhedron, vector(vec)) 
            projection_graphs[graph].append(vec)

    logging.debug(" All done finding projection graphs!")


    logging.debug(" Found %d unique graphs from %d vectors" %( len(projection_graphs), len(normals)))

    # Get a list of enough colors - one for each unique graph
    # Then build a map between the graphs and tachyon textures
    colors = rainbow(len(projection_graphs),format='rgbtuple')
    logging.debug(" Colors for this graphic: %s" % ( colors ))
    vector_textures = {}

    # Build textures for each color, then populates a map
    # between textures and normals (the projection vectors.)
    logging.debug(" Adding textures to tachyon scene.")
    for graph in projection_graphs.keys():
        this_texture_id = str(len(colors))
        this_color = colors.pop()

        t.texture(this_texture_id, color=this_color)
        vector_textures[this_texture_id] = projection_graphs[graph]


    # associate a color with each face then add the corresponding triangle
    # to the tachyon scene.
    logging.debug(" Adding triangles to tachyon scene.")
    for face,normal in normals.items():
    	verts = map(lambda v: list(v), face.vertices())
        this_texture = next(k for k,v in vector_textures.items() if v.count(normal) )
        t.triangle(verts[0], verts[1], verts[2], this_texture)

    return t
