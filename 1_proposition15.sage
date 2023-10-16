load("tools.sage")


# binary_code: a string of fifteen characters '0' and '1'
# Returns: a tournament of \mathcal{F}. The orientations of the fifteen non-forced arcs correspond to the characters of binary_code.
def digraph_blowup_TT3(binary_code):
    iterator_binary_code = iter(binary_code)
    d = DiGraph(9)
    #the vertices 0,...,8 correspond respectively to u_1,...,u_6,x_1,x_2,x_3
    
    #add the arcs of the TT_6
    for i in range(6):
        for j in range(i):
            d.add_edge(j,i)
            
    #add the arcs of the directed triangles
    for i in range(3):
        d.add_edge(6+i, 2*i)
        d.add_edge(2*i+1, 6+i)
    
    missing_edges=[(6,2),(6,3),(6,4),(6,5),(6,7),(6,8),(7,0),(7,1),(7,4),(7,5),(7,8),(8,0),(8,1),(8,2),(8,3)]
    #we orient the missing_edges according to binary_code
    for e in missing_edges:
        if(next(iterator_binary_code) == '0'):
            d.add_edge(e[0],e[1])
        else:
            d.add_edge(e[1],e[0])
    return d

print("Computing all possible candidates of \mathcal{F} for being a subtournament of a 3-dicritical semi-complete digraph...")
list_candidates = []
list_forbidden_induced_subdigraphs = [C3_C3]

#print progress bar
printProgressBar(0, 2**15)

#main
for i in range(2**15):
    binary_value = bin(i)[2:]
    while(len(binary_value)<15):
        binary_value = '0' + binary_value
    d = digraph_blowup_TT3(binary_value)
    if(can_be_subgraph_of_3_dicritical(d,[],list_forbidden_induced_subdigraphs)):
        list_candidates.append(d)
    #update progress bar
    printProgressBar(i + 1, 2**15)

print("Number of candidates: ",len(list_candidates),".")
for i in range(len(list_candidates)):
    print("Candidate ",i+1,": ")
    list_candidates[i].export_to_file("T"+str(i+1)+".pajek")
    print(list_candidates[i].adjacency_matrix())
    


