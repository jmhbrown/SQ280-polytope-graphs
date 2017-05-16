from sage.geometry.polyhedron.parent import Polyhedra
from collections import defaultdict

# Basic code for turning a vector and a polyhedron into a graph

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

def visible_graph(polyhedron, projection_vector):
    """
    Returns an immutable, canonical version of the visible graph
         - if opposite_graph=True, then returns the opposite graph as well
    """
    # TODO: Maybe we should remove all the visible faces stuff?
    faces,opposite_faces = visible_faces(polyhedron,projection_vector)
    visible_graph = Graph(face_list_to_graph(faces)).canonical_label().copy(immutable=True)

    return visible_graph


def vertex_visible_graphs(polyhedron):
    """
    Makes a dictionary of visible graphs, whose keys are immutable graphs
    and whose values are lists of vectors.

    Only considered surface normals, edge normals, and vertices.
    """
    graphs = defaultdict(lambda: [])
    surface_normals = get_surface_normals(polyhedron)
    edge_normals = get_edge_normals(polyhedron)
    vertex_normals = map(lambda v: vector(v), square_from_vertices.vertices())

    for n in surface_normals:
        this_graph = visible_graph(polyhedron, n)
        graphs[this_graph].append(n)

    for n in edge_normals:
        this_graph = visible_graph(polyhedron, n)
        graphs[this_graph].append(n)

    # Check each vertex too
    for v in vertex_normals:
        this_graph = visible_graph(polyhedron, v)
        graphs[this_graph].append(v)

    return graphs

def nice_plot(graphs):
    """
    Makes nice plots.

    `graphs`: A dictionary with `sage.graphs.graph.Graph` : [ vertex ]
    """

    for graph in graphs.keys():
        GP = graph.graphplot(layout='spring')
        GP.show()

# Example
square_from_vertices = Polyhedron(vertices = [[1,1,1], [1,1,-1],[1,-1,1],[1,-1,-1],[-1,1,1],[-1,1,-1],[-1,-1,1],[-1,-1,-1]])
        
graphs = vertex_visible_graphs(square_from_vertices)
print graphs

