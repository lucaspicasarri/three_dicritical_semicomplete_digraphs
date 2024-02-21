import networkx
load("tools.sage")

list_candidates = []
list_forbidden_induced_subdigraphs = [C3_C3]

#import T1, T2, T3 and T4
for i in range(1,5):
    candidate = DiGraph(9)
    nx = networkx.read_pajek("T"+str(i)+".pajek")
    for e in nx.edges():
        candidate.add_edge(int(e[0]),int(e[1]))
    list_candidates.append(candidate)

print("We start from the ", len(list_candidates), " candidates on 9 vertices.")

#We want to prove that a 3-dicritical semi-complete digraph does not contain a digraph in {F+,F-}. By directional duality, it is sufficient to prove that it does not contain F+.
#For each candidate computed above, we try to add a new vertex that dominates the transitive tournament, and then we build every possible orientation between this vertex and the three other vertices. 
print("Computing for F+...")
list_Fp = []
printProgressBar(0, 8)
for orientation in range(2**3):
    binary = bin(orientation)[2:]
    while(len(binary)<3):
        binary = '0' + binary
    for T9 in list_candidates:
        iterator = iter(binary)
        T10 = DiGraph(10)
        T10.add_edges(T9.edges())
        for v in range(6):
            T10.add_edge(9,v)
        for v in range(6,9):
            if(next(iterator) == '0'):
                T10.add_edge(v,9)
            else:
                T10.add_edge(9,v)
        check = can_be_subgraph_of_3_dicritical(T10,[],list_forbidden_induced_subdigraphs)
        if(check):
            list_Fm.append(T2)
    printProgressBar(orientation+1, 8)

print("Number of 1-extensions of {T1,T2,T3,T4} containing F+: ",len(list_Fp))
