from sage.geometry.polyhedron.parent import Polyhedra

def get_surface_normals(polyhedron):
    """
    Returns an array of surface normals

    `polyhedron`: a `Polyhedra`
    """
    normals = []
    for f in polyhedron.faces(2):
        normals.append(f.ambient_Hrepresentation()[0]._A)

    return normals

def get_edge_normals(polyhedron):
    """
    Returns an array of 'edge normals', i.e.
    all the sums of pairwise adjacent surfaces
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
    Returns an array of 'vertex normals', i.e.
    the vectors which connect the origin and each vertex
    """
    return map( lambda v: vector(v), polyhedron.vertices_list())
