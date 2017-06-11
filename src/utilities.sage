def parse_kwargs(kwargs, option, default):
    """

    INPUT:

        - ``kwargs`` --  A Dict. Keyword arguments.
        - ``option`` --  Any HashableType. Option key.
        - ``default`` -- Default value.

    OUTPUT:
        
        Returns the provided value if there was one, and the default value otherwise.
    """

    return kwargs[option] if kwargs.has_key(option) else default

def get_normals(polyhedron):
    """
    Returns a dictionary associating each face with its normal.

    INPUT:

        - ``polyhedron`` -- A Polyhedron. Required. Three dimensional Polyhedron

    OUTPUT:

        Dictionary of normal vectors. Keys are PolyhedronFace, values are Vector
    """
    logging.info(" Building map of surface normals.")
    normals = {}
    for face in polyhedron.faces(2):
        normals[face] = face.ambient_Hrepresentation()[0]._A

    return normals

def random_polyhedron(**kwargs):
    """
    Returns a random compact convex polyhedron.

    INPUT:

    - ``n_vertices`` -- Integer. Optional (default: 4) The number of vertices.

    OUTPUT:

        A Polyhedron with `n_vertices` vertices.
    """

    n_vertices = parse_kwargs(kwargs, 'n_vertices', 4)

    vertices = map(lambda x: vector((gauss(0,1) for d in range(3))).normalized(), range(n_vertices))
    return Polyhedron(vertices=vertices)
