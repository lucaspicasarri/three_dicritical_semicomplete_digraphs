load("tools.sage")

# graph_to_complete: DiGraph
# nb_vertices: the order of graph_to_complete
# v: vertex of d
# list_forbidden_subdigraphs: a list of DiGraphs
# list_forbidden_induced_subdigraphs: a list of DiGraphs
# progress: the integer for which the arcs between the vertex nb_vertices and the vertices [0,progress-1] have already been decided
# Returns: The list of all semi-complete digraphs on nb_vertices vertices that are equal to graph_to_complete when removing the vertex (nb_vertices-1) and are potentially subdigraphs of 3-dicritical semicomplete digraphs.
def possible_completions(graph_to_complete, nb_vertices, list_forbidden_subdigraphs, list_forbidden_induced_subdigraphs, progress=0):
    if(progress == nb_vertices-1): 
        return [graph_to_complete]
    else:
        result = []
        for i in range(3):
            #we make a copy of the graph_to_complete
            new_D = DiGraph(nb_vertices)
            new_D.add_edges(graph_to_complete.edges())
            
            #we consider every possible orientation between the vertices (nb_vertices-1) and (progress)
            if(i==0):
                new_D.add_edge(nb_vertices-1, progress)
            elif(i==1):
                new_D.add_edge(progress, nb_vertices-1)
            else:
                new_D.add_edge(nb_vertices-1, progress)
                new_D.add_edge(progress, nb_vertices-1)
                
            #for each of the 3 possible orientations, we check whether the obtained digraph is already an obstruction. If it is not, we compute all possible completions recursively
            if(can_be_subgraph_of_3_dicritical(new_D,list_forbidden_subdigraphs, list_forbidden_induced_subdigraphs)):
                result.extend(possible_completions(new_D, nb_vertices, list_forbidden_subdigraphs, list_forbidden_induced_subdigraphs, progress+1))
        return result

for tt in range(1,8):
    transitive_tournament = DiGraph(tt)
    for i in range(tt):
        for j in range(i):
            transitive_tournament.add_edge(j,i)

    next_transitive_tournament = DiGraph(tt+1)
    for i in range(tt+1):
        for j in range(i):
            next_transitive_tournament.add_edge(j,i)

    list_forbidden_subdigraphs = [S4, K2_K2, O4, O5, K2_C3, C3_K2, C3_C3, F]
    list_forbidden_induced_subdigraphs = []
    if(tt<7):
        list_forbidden_induced_subdigraphs = [next_transitive_tournament]
    else:
        list_forbidden_induced_subdigraphs = reversed_TT8

    print("\n--------------------------------------------------------\n")
    print("Generating all 3-dicritical semi-complete digraphs with maximum acyclic induced subdigraph of size exactly " + str(tt) + ".")
    
    n=tt+1
    candidates = [transitive_tournament]
    next_candidates = []
    while(len(candidates)>0):
        print("\nComputing candidates on "+str(n)+" vertices.")
        printProgressBar(0, len(candidates))
        for i in range(len(candidates)):
            old_D = candidates[i]
            new_D = DiGraph(n)
            new_D.add_edges(old_D.edges())
            all_possible_completions_new_D = possible_completions(new_D, n, list_forbidden_subdigraphs, list_forbidden_induced_subdigraphs)
            for candidate in all_possible_completions_new_D:
                check = True
                for D in next_candidates:
                    check = not D.is_isomorphic(candidate)
                    if(not check):
                        break
                if(check):
                    next_candidates.append(candidate)
            printProgressBar(i + 1, len(candidates))

        #check the candidates that are actually 3-dicritical.
        print("We found",len(next_candidates),"candidates on "+str(n)+" vertices.")
        dicriticals = []
        for D in next_candidates:
            if(not is_two_dicolourable(D)):
                dicriticals.append(D)
        print(len(dicriticals), " of them are actually 3-dicritical.\n")
        for D in dicriticals:
            print("adjacency matrix of a 3-dicritical digraph that we found:")
            print(D.adjacency_matrix())

        candidates = next_candidates
        next_candidates = []
        n+=1
