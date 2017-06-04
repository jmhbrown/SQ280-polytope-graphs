from sage.geometry.polyhedron.parent import Polyhedra
import logging

logging.basicConfig(level=logging.DEBUG)

# Makes a triangulation of a unit sphere.

def triangulated_sphere(subdivisions=3):
    """
    Makes a triangulation of a unit sphere, by repeatedly dividing the faces of an octahedron.
    The final triangulation will have `8*4^(subdivisions-1) = 2*4^(subdivision)` sides.
    @params:
        subdivisions     - Optional : # of times to divide faces.
                        
    """

    poly = polytopes.octahedron()
    new_verts = poly.vertices_list();

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

    return poly


def safe_normalize(vector):
    """
    Normalizes non-zero vectors, and leaves the zero vector unchanged.
    Useful since Vector.normalize() throws an error if handed the zero vector.
    @params:
        vector  - Required  : vector to normalize
    """
    if vector.is_zero():
        return vector
    else:
        return vector.normalized()

def make_numeric(vector):
    """
    Tries to numerically approximate a vector. Leaves the vector unchanged if it fails.
    Useful since Vector.numerical_approx() throws an error over certain fields.
    @params:
        vector  - Required  : vector to approximate
    """
    try:
        return vector.numerical_approx()
    except Exception:
        return vector


