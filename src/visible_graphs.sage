from sage.geometry.polyhedron.parent import Polyhedra
from collections import defaultdict

def get_visible_faces(polyhedron, projection_vector):
    """
    Returns the visible faces.
        :param polyhedron:          Required. The three dimensional polyhedron.
            :type polyhedron:           Polyhedron
        :param projection_vector:   Required. The vector to project along.
            :type projection_vector:    Vector
        :returns:                   Array containing visible faces.
            :rtype:                 List[PolyhedronFace]
    """
    visible_faces = []
    for f in polyhedron.faces(2):
        dot = projection_vector.dot_product(f.ambient_Hrepresentation()[0]._A)
        if  dot > 0:
            visible_faces.append(f) 
            # TODO - might be better to de-duplicate the vertex list here.
            # depends on how efficient the polyhedron constructor is.
    return visible_faces


def faces_to_graph(faces):
    """
    Turns a list of faces into a graph
        :param faces:   List of faces.
            :type faces:    List[PolyhedronFace]
        :returns:       Adjacency dictionary for graph.
            :rtype:         Dict
    """
    graph = defaultdict(lambda: set([])) # default to a set so we can append the first neighbor
    these_vertices = flatten(map(lambda x: x.vertices(), faces)) #TODO - dedup this!
    for f in faces:
        for v in f.vertex_generator():
            for n in v.neighbors():
                if n in these_vertices:
                    graph[v].add(n)
    return {k: list(graph[k]) for k in graph} # convert values back to lists, so Graph() is happy

def get_visible_graph(polyhedron, projection_vector):
    """
    Finds the visible graph associated with a particular vector.
        :param polyhedron Polyhedron:       Required. Polyhedron whose visible graph we want to find.
        :param projection_vector Vector:    Required. Vector to project along.
        :returns:                           Immutable, canonical version of the visible graph.
            :rtype:                             Graph
    """
    faces = get_visible_faces(polyhedron,projection_vector)
    visible_graph = Graph(faces_to_graph(faces)).canonical_label().copy(immutable=True)

    return visible_graph
