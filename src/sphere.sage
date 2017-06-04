from sage.geometry.polyhedron.parent import Polyhedra
import logging, os

logging.basicConfig(level=logging.DEBUG)

# Makes a triangulation of a unit sphere.

# TODO -    Don't rely on Sage converting to a polyhedron at each iteration.
#           sort out the neighbors structure independently, for performance reasons.
def triangulated_sphere(seed_poly=polytopes.octahedron(), save_poly=False, save_filepath=os.getcwd()+'/%s_sphere' % str(randint(0,2^10)), subdivisions=3):
    """
    Makes a triangulation of a unit sphere, by repeatedly dividing the faces of an octahedron.
    The final triangulation will have `8*4^(subdivisions-1) = 2*4^(subdivision)` sides.
        :param seed_poly:       Polytope from a previous run. Optional.
            :type seed_poly:        Polyhedron
        :param subdivisions:    # of times to divide faces. Optional.
            :type subdivisions:     str
        :param save_poly:       Whether to save the polytope. Optional.
            :type save_poly:        Boolean
        :param save_filepath:   Where to save the polytope. Optional.
            :type save_filepath:    str

        :return:                Triangulation of the sphere.
            :rtype:                 Polyhedron
                        
    """

    new_verts = seed_poly.vertices_list();
    poly = seed_poly

    # Make the new list.
    for i in range(0,subdivisions):
        logging.debug(" Working sphere subdivision # %d" % (i+1))
        for v in poly.vertices():
            for n in v.neighbors():
                avg = (v.vector() + n.vector())/2
                if new_verts.count(safe_normalize(avg)) == 0:
                    new_verts.append(safe_normalize(avg))
        poly = Polyhedron(vertices = map(lambda v: make_numeric(v), new_verts))
        new_verts = poly.vertices_list();

    poly.save(save_filepath)
    return poly

def safe_normalize(vector):
    """
    Normalizes non-zero vectors, and leaves the zero vector unchanged.
    Useful since Vector.normalize() throws an error if handed the zero vector.
        :param vector:      Vector to normalize. Required.
            :type vector:   Vector
        :return:            Normalized vector.
            :rtype:         Vector
    """
    if vector.is_zero():
        return vector
    else:
        return vector.normalized()

def make_numeric(vector):
    """
    Tries to numerically approximate a vector. Leaves the vector unchanged if it fails.
    Useful since Vector.numerical_approx() throws an error over certain fields.
        :param vector:      Vector to numerially approximate. Required.
            :type vector:   Vector
        :return:            Approximated vector.
            :rtype:         Vector
    """
    try:
        return vector.numerical_approx()
    except Exception:
        return vector
