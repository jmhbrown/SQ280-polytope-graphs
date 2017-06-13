def parse_kwargs(kwargs, option, default):
    """

    INPUT::

        - ``kwargs`` --  A Dict. Keyword arguments.
        - ``option`` --  Any HashableType. Option key.
        - ``default`` -- Default value.

    OUTPUT::

        Returns the provided value if there was one, and the default value otherwise.

    EXAMPLES::

	Loading the code:

	    sage: load('utilities.sage')

	Usage:

            sage: kwargs = {'option1': 'value1', 'option2': 'value2'}
            sage: parse_kwargs(kwargs, 'option1', 'DEFAULT')
            'value1'
            sage: parse_kwargs(kwargs, 'missing_option', 'DEFAULT')
            'DEFAULT'

    """

    return kwargs[option] if kwargs.has_key(option) else default

def get_normals(polyhedron):
    """
    Returns a dictionary associating each face with its normal.

    INPUT::

        - ``polyhedron`` -- A Polyhedron. Required. Three dimensional Polyhedron

    OUTPUT::

        Dictionary of normal vectors. Keys are PolyhedronFace, values are Vector

    EXAMPLES::

	Loading the code:

	    sage: load('utilities.sage')

	Usage:

           sage: get_normals(polytopes.cube())
           INFO:root: Building map of surface normals.

           {<0,1,2,3>: (1, 0, 0),
            <0,1,4,5>: (0, 1, 0),
            <0,2,4,6>: (0, 0, 1),
            <1,3,5,7>: (0, 0, -1),
            <2,3,6,7>: (0, -1, 0),
            <4,5,6,7>: (-1, 0, 0)}


    """
    logging.info(" Building map of surface normals.")
    normals = {}
    for face in polyhedron.faces(2):
        normals[face] = face.ambient_Hrepresentation()[0]._A

    return normals

def random_polyhedron(**kwargs):
    """
    Returns a random compact convex polyhedron.

    INPUT::

    - ``n_vertices`` -- Integer. Optional (default: 4) The number of vertices.

    OUTPUT::

        A Polyhedron with `n_vertices` vertices.

    EXAMPLES::

	Loading the code:

	    sage: load('utilities.sage')

	Usage:

            sage: poly = random_polyhedron(n_vertices=7)
            sage: poly
            A 3-dimensional polyhedron in RDF^3 defined as the convex hull of 7 vertices

    """

    n_vertices = parse_kwargs(kwargs, 'n_vertices', 4)

    vertices = map(lambda x: vector((gauss(0,1) for d in range(3))).normalized(), range(n_vertices))
    return Polyhedron(vertices=vertices)
