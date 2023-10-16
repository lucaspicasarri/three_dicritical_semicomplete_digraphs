# The following function displays a progress bar
def printProgressBar (iteration, total):
    percent = ("{0:.1f}").format(100 * (iteration / float(total)))
    filledLength = int(50 * iteration // total)
    bar = "#" * filledLength + "-" * (50 - filledLength)
    print(f"\rProcess: |{bar}| {percent}% Complete", end = "\r")
    # Print New Line on Complete
    if iteration == total: 
        print()

# k,n : integers such that k < 3**n
# Returns: the decomposition of k in base 3 of length n
def ternary(k,n):
    b = 3**(n-1)
    res=""
    for i in range(n):
        if(k >= 2*b):
            k -= 2*b
            res = res + "2"
        elif(k >= b):
            k -= b
            res = res + "1"
        else:
            res = res + "0"
        b /= 3
    return res

# d: DiGraph
# u: vertex
# v: vertex
# Returns: True if and only if d contains a directed path from u to v
def contains_directed_path(d,u,v):
    to_be_treated = [u]
    i=0
    while(len(to_be_treated) != i):
        x = to_be_treated[i]
        if (x==v):
            return True
        for y in d.neighbors_out(x):
            if (not y in to_be_treated):
                to_be_treated.append(y)
        i+=1
    return False

# d: DiGraph
# u: vertex of d
# v: vertex of d
# current_colouring: partial 2-dicolouring with colours {0,1} of d such that current_colouring[u] = current_colouring[v] = 0
# Returns: True if and only if current_colouring can be extended into a 2-dicolouring of d with no monochromatic directed path from u to v.
def can_be_subgraph_of_3_dicritical_aux(d,u,v, current_colouring):
    #build the colour classes
    colours = {}
    colours[0] = []
    colours[1] = []
    for (x,i) in current_colouring.items():
        colours[i].append(x)
    #check whether both colour classes are acyclic
    for i in range(2):
        d_i = d.subgraph(colours[i])
        if(not d_i.is_directed_acyclic()):
            return False
    #check whether there is a monochromatic directed path from u to v
    d_0 = d.subgraph(colours[0])
    if(contains_directed_path(d_0,u,v)):
        return False
    #check whether current_colouring is partial
    if(len(current_colouring) == d.order()):
        return True
    else:
        #find a vertex x that is not coloured yet
        x = len(current_colouring)
        while(x in current_colouring):
            x-=1
        #check recursively whether current_colouring can be extended to x
        for i in range(2):
            current_colouring[x] = i
            if(can_be_subgraph_of_3_dicritical_aux(d,u,v,current_colouring)):
                return True
            current_colouring.pop(x, None)
        return False

# d: DiGraph
# forbidden_subtournaments: list of DiGraphs
# Returns: True if and only if d is {forbidden_subdigraphs}-free, {forbidden_induced_subdigraphs}-free  and, for every arc (u,v) of d, d admits a uv-colouring.
def can_be_subgraph_of_3_dicritical(d, forbidden_subdigraphs, forbidden_induced_subdigraphs):
    #check whether d contains a forbidden subgraph
    for T in forbidden_subdigraphs:
        if(d.subgraph_search(T, False) != None):
            return False
    #check whether d contains a forbidden induced subgraph
    for T in forbidden_induced_subdigraphs:
        if(d.subgraph_search(T, True) != None):
            return False
    #check for every arc uv if d admits a uv-colouring.
    for e in d.edges():
        d_aux = DiGraph(len(d.vertices()))
        d_aux.add_edges(d.edges())
        d_aux.delete_edge(e)
        current_colouring = {}
        current_colouring[e[0]] = 0
        current_colouring[e[1]] = 0
        if(not can_be_subgraph_of_3_dicritical_aux(d_aux,e[0],e[1], current_colouring)):
            return False
    return True

# d: DiGraph
# Returns: True if and only if d is 2-dicolourable
def is_two_dicolourable(d):
    n = d.order()
    for bipartition in range(2**n):
        #build the binary word corresponding to the bipartition
        binary = bin(bipartition)[2:]
        while(len(binary)<(n)):
            binary = "0" + binary
        #build the bipartition
        V1 = []
        V2 = []
        for v in range(n):
            if(binary[v] == '0'):
                V1.append(v)
            else:
                V2.append(v)
        #check whether (V1,V2) is actually a dicolouring
        d1 = d.subgraph(V1)
        d2 = d.subgraph(V2)
        if(d1.is_directed_acyclic() and d2.is_directed_acyclic()):
            return True
    return False

#C3_C3 is the digraph made of two disjoint directed triangles, the vertices of one dominating the vertices of the other
C3_C3 = DiGraph(6)
for i in range(3):
    C3_C3.add_edge(i,(i+1)%3)
    C3_C3.add_edge(i+3,((i+1)%3)+3)
    for j in range(3,6):
        C3_C3.add_edge(i,j)

#F is the digraph on nine vertices made of a TT6 u1,...,u6 and the arcs of the directed triangles u1u2x1u1, u3u4x2u3, u5u6x3u5. 
F = DiGraph(9)
for i in range(6):
    for j in range(i):
        F.add_edge(j,i)
F.add_edge(6,0)
F.add_edge(1,6)
F.add_edge(7,2)
F.add_edge(3,7)
F.add_edge(8,4)
F.add_edge(5,8)

#TT8 is the transitive tournament on 8 vertices
TT8 = DiGraph(8)
for i in range(8):
    for j in range(i):
        TT8.add_edge(j,i)

#reversed_TT8 is the set of tournaments, up to isomorphism, obtained from TT8 by reversing exactly one arc
reversed_TT8 = []
for e in TT8.edges():
    rev = DiGraph(8)
    rev.add_edges(TT8.edges())
    rev.delete_edge(e)
    rev.add_edge(e[1],e[0])
    check = True
    for T in reversed_TT8:
        check = check and (not T.is_isomorphic(rev))
    if(check):
        reversed_TT8.append(rev)

#K2 is the complete digraph on 2 vertices
K2 = DiGraph(2)
K2.add_edge(0,1)
K2.add_edge(1,0)

#S4 is the bidirected star on 4 vertices
S4 = DiGraph(4)
for i in range(1,4):
    S4.add_edge(i,0)
    S4.add_edge(0,i)

#C3_K2 is the digraph with a directed triangle dominating a digon. 
C3_K2 = DiGraph(5)
for i in range(3):
    C3_K2.add_edge(i,(i+1)%3)
    for j in range(3,5):
        C3_K2.add_edge(i,j)
C3_K2.add_edge(3,4)
C3_K2.add_edge(4,3)

#K2_C3 is the digraph with a digon dominating a directed triangle
K2_C3 = DiGraph(5)
for i in range(3):
    K2_C3.add_edge(i,(i+1)%3)
    for j in range(3,5):
        K2_C3.add_edge(j,i)
K2_C3.add_edge(3,4)
K2_C3.add_edge(4,3)

#K2_K2 is the digraph with a digon dominating a digon
K2_K2 = DiGraph(4)
for i in range(2):
    K2_K2.add_edge(i,(i+1)%2)
    K2_K2.add_edge(i+2,((i+1)%2)+2)
    for j in range(2,4):
        K2_K2.add_edge(i,j)

#O4 and O5 are the obstructions described in the paper.
O4 = DiGraph(4)
for i in range(1,4):
    O4.add_edge(0,i)
for i in range(1,3):
    O4.add_edge(i,3)
O4.add_edge(1,2)
O4.add_edge(2,1)

O5 = DiGraph(5)
for i in range(1,5):
    O5.add_edge(0,i)
for i in range(1,4):
    O5.add_edge(i,4)
O5.add_edge(1,2)
O5.add_edge(2,3)
O5.add_edge(3,1)
