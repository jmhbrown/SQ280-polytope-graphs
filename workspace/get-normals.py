# Very rough test code, used to work with outwards normals of polyhedra
# Uses sage for most heavy lifting.

from sage.geometry.polyhedron.parent import Polyhedra

square_from_vertices = Polyhedron(vertices = [[1,1,1], [1,1,-1],[1,-1,1],[1,-1,-1],[-1,1,1],[-1,1,-1],[-1,-1,1],[-1,-1,-1]])

for f in square_from_vertices.faces(2):
        print f.ambient_Hrepresentation()[0]._A
