from sage.geometry.polyhedron.parent import Polyhedra

def get_surface_normals(polyhedron):
    """
    Returns an array of surface normals

    INPUT:

        - ``polyhedron`` -- Polyhedron. The Polyhedron.

    OUTPUT:

        A list of the vectors corresponding to 'surface normals'.
    """
    normals = []
    for f in polyhedron.faces(2):
        normals.append(f.ambient_Hrepresentation()[0]._A)

    return normals

def get_edge_normals(polyhedron):
    """
    Returns an array of 'edge normals', i.e. all the sums of pairwise adjacent surfaces

    INPUT:

        - ``polyhedron`` -- Polyhedron. The Polyhedron.

    OUTPUT:

        A list of the vectors corresponding to 'edge normals'.
    """
    edge_norms = set([])
    for v in polyhedron.vertex_generator():
        for n in v.neighbors():
            edge_n = vector(v) + vector(n)
            edge_n.set_immutable()
            edge_norms.add(edge_n)

    return list(edge_norms) # convert back to list

def get_vertex_normals(polyhedron):
    """
    Returns an array of 'vertex normals', i.e. the vectors which connect the origin and each vertex

    INPUT:

        - ``polyhedron`` -- Polyhedron. The Polyhedron.

    OUTPUT:

        A list of the vectors corresponding to the vertices.
    """
    return map( lambda v: vector(v), polyhedron.vertices_list())
