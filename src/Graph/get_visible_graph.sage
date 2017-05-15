from sage.geometry.polyhedron.parent import Polyhedra
from collections import defaultdict

# Basic code for turning a vector and a polyhedron into a graph

def visible_faces(polyhedron, projection_vector):
    """
    Returns the visible and hidden faces
    """
    visible_faces = []
    hidden_faces = []
    for f in polyhedron.faces(2):
        dot = projection_vector.dot_product(f.ambient_Hrepresentation()[0]._A)
        if  dot > 0:
            visible_faces.append(f) 
            # TODO - might be better to de-duplicate the vertex list here.
            # depends on how efficient the polyhedron constructor is.
        elif dot < 0:
            hidden_faces.append(f)
    return visible_faces, hidden_faces
    
def face_list_to_graph(faces):
    """
    Turns a list of faces into a graph
    """
    graph = defaultdict(lambda: set([])) # default to a set so we can append the first neighbor
    these_vertices = flatten(map(lambda x: x.vertices(), faces)) #TODO - dedup this!
    for f in faces:
        for v in f.vertex_generator():
            for n in v.neighbors():
                if n in these_vertices:
                    graph[v].add(n)
    return {k: list(graph[k]) for k in graph} # convert values back to lists, so Graph() is happy

def visible_graph(polyhedron, projection_vector, opt={'opposite_graph': False}):
    """
    Returns an immutable, canonical version of the visible graph
         - if opposite_graph=True, then returns the opposite graph as well
    """
    faces,opposite_faces = visible_faces(polyhedron,projection_vector)
    visible_graph = Graph(face_list_to_graph(faces)).canonical_label().copy(immutable=True)
    if opt['opposite_graph']:
        opposite_graph = Graph(face_list_to_graph(opposite_faces)).canonical_label().copy(immutable=True)
        return visible_graph, opposite_graph

    return visible_graph



# Example
proj_vector = vector(AA, [1,1,1/2])
square_from_vertices = Polyhedron(vertices = [[1,1,1], [1,1,-1],[1,-1,1],[1,-1,-1],[-1,1,1],[-1,1,-1],[-1,-1,1],[-1,-1,-1]])
print("get_visible_graph imported and ran!")

#graph,back_graph = visible_graph(square_from_vertices, proj_vector, {'opposite_graph': True})
