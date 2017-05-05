from sage.geometry.polyhedron.parent import Polyhedra


square_from_vertices = Polyhedron(vertices = [[1,1,1], [1,1,-1],[1,-1,1],[1,-1,-1],[-1,1,1],[-1,1,-1],[-1,-1,1],[-1,-1,-1]])


#for f in square_from_vertices.faces(2):
#  print f.ambient_Hrepresentation()[0]._A
visible_faces = []

# TODO - running in the interpreter, looks like a floor function is called on everything.
def visible_graph(polyhedron, projection_vector):
    for f in polyhedron.faces(2):
        dot = projection_vector.dot_product(f.ambient_Hrepresentation()[0]._A)
        print "f: %s, dot: %s" % ( f, dot.__class__)
        if  dot > 0:
            visible_faces.append(f) 
            print f
    print visible_faces
    return visible_faces



proj_vector = vector(AA, [1,1,1/2])

visible_faces = visible_graph(square_from_vertices, proj_vector)
