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

