from sage.geometry.polyhedron.parent import Polyhedra
from multiprocessing.dummy import Pool as ThreadPool
import logging, os
load('utilities.sage')

logging.basicConfig(level=logging.DEBUG)

# Makes a triangulation of a unit sphere.

# TODO -    Don't rely on Sage converting to a polyhedron at each iteration.
#           sort out the neighbors structure independently, for performance reasons.
def triangulated_sphere(**kwargs):
    """
    Makes a triangulation of a unit sphere, by repeatedly dividing the faces of an octahedron.
    The final triangulation will have `8*4^(subdivisions-1) = 2*4^(subdivision)` sides.

    INPUT:

        - ``seed_poly`` --  A Polyhedron. Optional. Defaults to an octahedron. Base polytope to apply iterations to.
        - ``n_iterations`` --  An Integer. Optional. Number of times to divide faces.
        - ``multithreaded`` -- Bool. Optional. Whether to run in multithreaded mode.

        Save Options:
        - ``save_poly`` --  Bool. Optional. Defaults to False. Whether to save the polytope
        - ``save_filepath`` --  String. Optional. Defaults to cwd+'/output'. Directory to save the polytope in.
        - ``save_filename`` --  String. Optional. Filename used for save file.

    OUTPUT:

        A polyhedron corresponding to a Triangulation of the sphere.

    """

    poly = parse_kwargs(kwargs, 'seed_poly', polytopes.octahedron())
    new_verts = poly.vertices_list();

    n_iterations = parse_kwargs(kwargs, 'n_iterations', 3)
    multithreaded = parse_kwargs(kwargs, 'multithreaded', False)
    if multithreaded:
        logging.info(" Running in multithreaded mode!")

    # Make the new list.
    for i in range(1, n_iterations+1):
        logging.debug(" Working sphere subdivision # %d (of %d)" % (i, n_iterations))
        if multithreaded:
            pool = ThreadPool(4)
            # XXX - this will add two of each new vertex. Non-ideal, but it doesn't seem to cause issues.
            new_verts_tmp = pool.map(
                    lambda v: list(safe_normalize((v.vector()+n.vector())/2) for n in v.neighbors()),
                    poly.vertices()
                )
            pool.close()
            pool.join()
            new_verts.extend(flatten(new_verts_tmp))
        else:
            for v in poly.vertices():
                for n in v.neighbors():
                    avg = (v.vector() + n.vector())/2
                    if new_verts.count(safe_normalize(avg)) == 0:
                        new_verts.append(safe_normalize(avg))
        poly = Polyhedron(vertices = map(lambda v: make_numeric(v), new_verts))
        new_verts = poly.vertices_list();

    # Optionally, save the generated sphere for later use.
    save_poly = parse_kwargs(kwargs, 'save_poly', False)
    if save_poly:
        default_filepath = os.getcwd()+"/output/"
        default_filename = "%s_sphere_%d_faces" % (
                datetime.datetime.now().strftime('%Y-%m-%d_%H:%M:%S'),
                poly.n_facets()
            )

        save_filename = parse_kwargs(kwargs, 'save_filename', default_filename)
        save_filepath = parse_kwargs(kwargs, 'save_filepath', default_filepath)
        # create the save directory, if necessary
        if not os.path.isdir(save_filepath):
            os.mkdir(save_filepath)

        if not save_filepath.endswith('/'):
            save_filepath += '/'

        if os.path.exists(save_filepath+save_filename):
            logging.warn(" Overwriting savefile %s" % save_filepath+save_filename)

        logging.info(" Saving triangulated sphere to %s" % save_filepath+save_filename)
        poly.save(save_filepath+save_filename)

    return poly

def safe_normalize(vector):
    """
    Normalizes non-zero vectors, and leaves the zero vector unchanged.
    Useful since Vector.normalize() throws an error if handed the zero vector.

    INPUT:

        - ``vector`` -- Required. Vector to normalize.

    OUTPUT:

        Normalized vector.
    """
    if vector.is_zero():
        return vector
    else:
        return vector.normalized()

def make_numeric(vector):
    """
    Tries to numerically approximate a vector. Leaves the vector unchanged if it fails.
    Useful since Vector.numerical_approx() throws an error over certain fields.

    INPUT:

        - ``vector`` --  Required. Vector to numerially approximate.

    OUTPUT:

        Approximated vector.
    """
    try:
        return vector.numerical_approx()
    except Exception:
        return vector
