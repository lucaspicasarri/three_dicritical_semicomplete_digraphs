import networkx
load("tools.sage")

all_candidates = []
current_candidates = []
next_candidates = []

list_forbidden_subdigraphs = [S4, K2_K2, O4, O5, K2_C3, C3_K2, C3_C3]
list_forbidden_induced_subdigraphs = [TT8]

#import the candidates T1, ..., T4 on 9 vertices:
for i in range(1,5):
    candidate = DiGraph(9)
    nx = networkx.read_pajek("T"+str(i)+".pajek")
    for e in nx.edges():
        candidate.add_edge(int(e[0]),int(e[1]))
    current_candidates.append(candidate)
print("We start from the tournaments {T^1,T^2,T^3,T^4} on 9 vertices, and look for every possible completion of them that is potentially a subdigraph of a larger 3-dicritical semi-complete digraphs.\n")


all_candidates.extend(current_candidates)
#completions of T1, ..., T4
while(len(current_candidates)>0):
    for old_D in current_candidates:
        for e in old_D.edges():
            #we try to complete old_D by replacing e by a digon. It actually makes sense only if e is not already in a digon.
            if(not (e[1],e[0],None) in old_D.edges()):
                new_D = DiGraph(9)
                new_D.add_edges(old_D.edges())
                new_D.add_edge(e[1],e[0])
                #we check whether this completion of old_D is pontentially a subdigraph of a larger 3-dicritical semi-complete digraph.
                check = can_be_subgraph_of_3_dicritical(new_D,list_forbidden_subdigraphs, list_forbidden_induced_subdigraphs)
                for D in next_candidates:
                    check = check and (not D.is_isomorphic(new_D))
                if(check):
                    next_candidates.append(new_D)
    all_candidates.extend(next_candidates)
    current_candidates = next_candidates
    next_candidates=[]

print("-----------------------------------------")
print("There are",len(all_candidates),"possible completions (up to isomorphism) of {T^1,T^2,T^3,T^4} that are potentially subdigraphs of a larger 3-dicritical semi-complete digraphs.\n")

count_dic_3 = 0
for D in all_candidates:
    if(not is_two_dicolourable(D)):
        count_dic_3 += 1
print(count_dic_3, " of them have dichromatic number at least 3. In particular,",count_dic_3,"of them are 3-dicritical.\n")

current_candidates = all_candidates
next_candidates = []
for n in range(10,12):
    #computes the extensions on n vertices of {T1,T2,T3,T4}   
    print("-----------------------------------------")
    print("Computing "+str(n-9)+"-extensions of the candidates on 9 vertices that are potentially subdigraphs of a 3-dicritical semicomplete digraph (up to isomorphism).")
    printProgressBar(0, 3**(n-1))

    for orientation in range(3**(n-1)):
        ternary_code = ternary(orientation,n-1)
        #build every 1-extension of current_candidates
        for old_D in current_candidates:
            new_D = DiGraph(n)
            new_D.add_edges(old_D.edges())
            for v in range(n-1):
                if(ternary_code[v] == '0'):
                    new_D.add_edge(v,n-1)
                elif(ternary_code[v]=='1'):
                    new_D.add_edge(n-1,v)
                else:
                    new_D.add_edge(v,n-1)
                    new_D.add_edge(n-1,v)
            check = can_be_subgraph_of_3_dicritical(new_D,list_forbidden_subdigraphs,list_forbidden_induced_subdigraphs)
            for D in next_candidates:
                check = check and (not new_D.is_isomorphic(D))
            if(check):
                next_candidates.append(new_D)
        printProgressBar(orientation+1, 3**(n-1))

    print("Number of ", n-9,"-extensions up to isomorphism: ",len(next_candidates))
    #check if one of the candidates has dichromatic number at least 3.
    count_dic_3 = 0
    for D in next_candidates:
        if(not is_two_dicolourable(D)):
            count_dic_3 += 1
    print(count_dic_3, " of them have dichromatic number at least 3. In particular,", count_dic_3,"of them are 3-dicritical.\n")
    current_candidates = next_candidates
    next_candidates = []

