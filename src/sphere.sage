from sage.geometry.polyhedron.parent import Polyhedra
from multiprocessing.dummy import Pool as ThreadPool
import logging, os, datetime
load('utilities.sage')

logging.basicConfig(level=logging.INFO)

# Makes a triangulation of a unit sphere.

# TODO -    Don't rely on Sage converting to a polyhedron at each iteration.
#           sort out the neighbors structure independently, for performance reasons.
def triangulated_sphere(**kwargs):
    """
    Makes a triangulation of a unit sphere, by repeatedly dividing the faces of an octahedron.
    The final triangulation will have `8*4^(subdivisions-1) = 2*4^(subdivision)` sides.

    INPUT::

        - ``seed_sphere`` --  A Polyhedron. Optional. Defaults to an octahedron. Base polytope to apply iterations to.
        - ``n_iterations`` --  An Integer. Optional. Number of times to divide faces.
        - ``multithreaded`` -- Bool. Optional. Whether to run in multithreaded mode.

        Save Options:

        - ``save_poly`` --  Bool. Optional. Defaults to False. Whether to save the polytope
        - ``save_filepath`` --  String. Optional. Defaults to cwd+'/output'. Directory to save the polytope in.
        - ``save_filename`` --  String. Optional. Filename used for save file.

    OUTPUT::

        A polyhedron corresponding to a Triangulation of the sphere.

    EXAMPLES::

	Loading the code:

	    sage: cd $PATH_TO_REPO/SQ280-polytope-graphs/src
	    sage: load('sphere.sage')

	By default, creates a polyhedron with 258 vertices.

	    sage: sphere = triangulated_sphere()
	    INFO:root: Starting with a polyhedron on 6 vertices.
	    INFO:root: Working sphere subdivision # 1 (of 3)
	    INFO:root: Working sphere subdivision # 2 (of 3)
	    INFO:root: Working sphere subdivision # 3 (of 3)
	    sage: sphere
	    A 3-dimensional polyhedron in RDF^3 defined as the convex hull of 258 vertices

	Changing the number of iterations and the seed sphere, then save the resulting polyhedron.

	    sage: sphere = triangulated_sphere(save_poly=True, seed_sphere=polytopes.octahedron(), n_iterations=2)
	    INFO:root: Starting with a polyhedron on 6 vertices.
	    INFO:root: Working sphere subdivision # 1 (of 2)
	    INFO:root: Working sphere subdivision # 2 (of 2)
	    INFO:root: Saving triangulated sphere to /home/jenny/code/SQ280-polytope-graphs/src/output/20170613_074629_sphere_66_vertices.sobj
	    sage: sphere
	    A 3-dimensional polyhedron in RDF^3 defined as the convex hull of 66 vertices

    """

    poly = parse_kwargs(kwargs, 'seed_sphere', polytopes.octahedron())
    new_verts = poly.vertices_list();
    logging.info(" Starting with a polyhedron on %d vertices." % len(new_verts))

    n_iterations = parse_kwargs(kwargs, 'n_iterations', 3)
    multithreaded = parse_kwargs(kwargs, 'multithreaded', False)
    if multithreaded:
        logging.info(" Running in multithreaded mode!")

    # Make the new list.
    for i in range(1, n_iterations+1):
        logging.info(" Working sphere subdivision # %d (of %d)" % (i, n_iterations))
        if multithreaded:
            pool = ThreadPool(4)
            # XXX - this will add two of each new vertex. Non-ideal, but it doesn't seem to cause issues.
            # XXX - Doesn't work for polyhedrons with symbolically defined vertices?
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
        default_filename = "%s_sphere_%d_vertices" % (
                datetime.datetime.now().strftime('%Y%m%d_%H%M%S'),
                poly.n_vertices()
            )

        save_filename = parse_kwargs(kwargs, 'save_filename', default_filename)
        save_filepath = parse_kwargs(kwargs, 'save_filepath', default_filepath)
        # create the save directory, if necessary
        if not os.path.isdir(save_filepath):
            os.mkdir(save_filepath)

        if not save_filepath.endswith('/'):
            save_filepath += '/'

        if os.path.exists(save_filepath+save_filename):
            logging.warn(" Overwriting savefile %s.sobj" % (save_filepath+save_filename))

        logging.info(" Saving triangulated sphere to %s.sobj" % (save_filepath+save_filename))
        poly.save(save_filepath+save_filename)

    return poly

def safe_normalize(vector):
    """
    Normalizes non-zero vectors and leaves the zero vector unchanged.
    Useful since Vector.normalize() throws an error if passed the zero vector.

    INPUT::

        - ``vector`` -- Required. Vector to normalize.

    OUTPUT::

        Normalized vector.

    EXAMPLES::

	Loading the code:

	    sage: cd $PATH_TO_REPO/SQ280-polytope-graphs/src
	    sage: load('sphere.sage')

	Normalizing vectors:

	    sage: safe_normalize(vector([0,0,0]))
	    (0, 0, 0)
	    sage: safe_normalize(vector([0,1,1]))
	    (0, 1/2*sqrt(2), 1/2*sqrt(2))

    """
    if vector.is_zero():
        return vector
    else:
        return vector.normalized()

def make_numeric(vector):
    """
    Tries to numerically approximate a vector. Leaves the vector unchanged if it fails.
    Useful since Vector.numerical_approx() throws an error over certain fields.

    INPUT::

        - ``vector`` --  Required. Vector to numerially approximate.

    OUTPUT::

        Approximated vector.

    EXAMPLES::

	Loading the code:

	    sage: cd $PATH_TO_REPO/SQ280-polytope-graphs/src
	    sage: load('sphere.sage')

	Converting vectors:

	    sage: v = vector([1,1,1]).normalized()
	    sage: v.base_ring()
	    Symbolic Ring
	    sage: make_numeric(v).base_ring()
	    Real Field with 53 bits of precision
    """
    try:
        return vector.numerical_approx()
    except Exception:
        return vector
