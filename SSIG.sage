l = 3               # Degree l isogenies we are looking for: l should be a prime not p or some power of such.
q = 227^2           # Field size
F = GF(q, name='a') # Createing field
F.modulus()     # Prints irreducible polynomial of the field
# print "Field F defined as Z_",83,"[x]/<",F.modulus(),">"
E1 = EllipticCurve(F,[-1,0]) # Define initial curve
IsoGraph = []    # List that shall contain the isogeny graph
print "Is the curve supersingular: ", not E1.is_ordinary()
IsoGraph.append([E1])   # Adds the initial node to the graph
# print "E1 j invariant: ", E1.j_invariant() # Get j invariant

def computeGraph(E, itt):
    O = E(0)                       # Defines origin as O
    D3 = O.division_points(l)      # The torsion-l points

    # Creating cyclic groups:
    CD3 = []
    for i in range(len(D3)):
        if not D3[i] == O:         # Remove identity point
            listRes = []           # Generate cyclic group:
            for j in range(1,l):
                listRes.append(j*D3[i])
            CD3.append(listRes)    # Adds the cyclic group

    # Remove dublicate cyclic groups:
    CCD3 = []
    CCD3.append(CD3[0])       # initiate list
    for i in range(1,len(CD3)):
        allready_defined = false
        for j in range(len(CCD3)):
            for k in range(len(CCD3[j])):
                if (CD3[i])[0] == (CCD3[j])[k]:
                    allready_defined = true
        if not allready_defined:
            CCD3.append(CD3[i])

    for j in range(len(IsoGraph)): # Persisting Iso list
        IsoGraph[itt].append([IsoGraph[j][0],0])

    #Find all degree l isogenies from our curve E:
    for i in range(len(CCD3)):
        Q = CCD3[i][0]     # Get generator Q of subgroup
        phi = E.isogeny(Q) # Creates phi : E --> E/<Q>=E2
        E2 = phi.codomain()# Get image of phi
        E2j = E2.j_invariant()# To simplify
        inList = false
        #Checks if we have already found and put the node in our graph:
        for j in range(len(IsoGraph)): 
            if E2j == IsoGraph[j][0].j_invariant():
                #If the node is in our graph do nothing
                inList = true
        if not inList:                 
            #If the node is not in our graph... well, put it there!
            IsoGraph.append([E2])
            #Since we have found a new node lets update our graph edges
            for k in range(itt+1):     
                IsoGraph[k].append([E2,0]) #Non of our previous found nodes hand an edge to our new node, so the number of edges is set to zero.

        # Update the edges of our node E:
        #Traverse through all known nodes in the list to find E2
        for j in range(1,len(IsoGraph[itt])): 
            if IsoGraph[itt][j][0].j_invariant() == E2j:
                #Add the kernel generating element to recreate the isogeny
                IsoGraph[itt][j].append(Q)    
                #Increment the number of edges from E to E2
                IsoGraph[itt][j][1] = IsoGraph[itt][j][1] + 1 
        print "E2 j invariant: ", E2j      # prints the j invariant of E2

itter = 0
while itter < len(IsoGraph):
    print ""
    print "==================================================="
    print ""
    print "itter: ", itter
    computeGraph(IsoGraph[itter][0], itter)
    itter = itter + 1

#Creates an latex formatted adjencicy matrix
def printLaTeXAdjencicyMatrix(IsoGraph):
    AdjacencyMatrix = r"\left(\begin{array}{c|"
    AdjacencyMatrix += 'c'*len(IsoGraph)
    AdjacencyMatrix += r"}"
    AdjacencyMatrix += r"&"
    for i in range(len(IsoGraph)):
        AdjacencyMatrix += r"%s" %(IsoGraph[i][0].j_invariant())
        if i < len(IsoGraph)-1:
            AdjacencyMatrix += r" & "
        else:
            AdjacencyMatrix += r" \\ \hline"
    for i in range(len(IsoGraph)):
        AdjacencyMatrix += r"%s & " %(IsoGraph[i][0].j_invariant())
        for j in range(1, len(IsoGraph[i])):
            AdjacencyMatrix += r"%s" %(IsoGraph[i][j][1])
            if j < len(IsoGraph[i])-1:
                AdjacencyMatrix += r" & "
            elif i < len(IsoGraph)-1:
                AdjacencyMatrix += r" \\"
    AdjacencyMatrix += r"\end{array}\right)"
    AdjacencyMatrix = AdjacencyMatrix.replace('*',' \cdot ')
    print AdjacencyMatrix                                #Prints tex code

#Creates a latex formatted isogeny graph drawn in tikz
def printLaTeXIsogenyGraph(IsoGraph):
    IsogenyGraph = r"\begin{tikzpicture}[rotate=12] \draw [fill=yellow!15,rounded corners, draw=black!50, dashed, rotate=-12] ([shift={(0.5\pgflinewidth,0.5\pgflinewidth)}]13,13) rectangle ([shift={(-0.5\pgflinewidth,-0.5\pgflinewidth)}]-13,-13);"
    for i in range(len(IsoGraph)):
        IsogenyGraph += r"\node[circle,draw=black,very thick,inner sep=4pt,minimum size=20pt] (v_%s) at (%s:11cm) {$%s$};" %(i,360/len(IsoGraph) *i,IsoGraph[i][0].j_invariant())
    #drawMAP
    for i in range(len(IsoGraph)):
        for j in range(1,len(IsoGraph[i])):
            if IsoGraph[i][j][1] > 0:
                if i == j-1:
                    IsogenyGraph += r"\draw[draw={rgb,255:red,150; green,%s; blue,%s}, very thick, ->] (v_%s) edge[out=90,in=45, loop] (v_%s);" %((i*20+20)%255,(i*50+20)%255,i,j-1)
                else:
                    if IsoGraph[i][j][1] > 1:
                        IsogenyGraph += r"\draw[draw={rgb,255:red,150; green,%s; blue,%s}, very thick, ->] (v_%s) edge[bend left=17] node[rectangle, draw={rgb,255:red,150; green,%s; blue,%s}, fill=yellow!15, midway]{$%s$} (v_%s);" %((i*20+20)%255,(i*50+20)%255,i,
                            (i*20+20)%255,(i*50+20)%255,
                            IsoGraph[i][j][1],j-1)
                    else:
                        IsogenyGraph += r"\draw[draw={rgb,255:red,150; green,%s; blue,%s}, very thick, ->] (v_%s) edge[bend left=17] (v_%s);" %((i*20+20)%255,(i*50+20)%255,i,j-1)
    IsogenyGraph += r"\end{tikzpicture}"
    IsogenyGraph = IsogenyGraph.replace('*',' \cdot ')    #Replaces bad typsetting * with \cdot
    print IsogenyGraph                                    #Prints tex code

#This ONLY works for graphs of SIZE divisible by 4!!!!!!
def prettyPrintIsogenyGraph(IsoGraph):
    IsogenyGraph = r"\begin{tikzpicture}[rotate=12] \draw [fill=yellow!15,rounded corners, draw=black!50, dashed, rotate=-12] ([shift={(0.5\pgflinewidth,0.5\pgflinewidth)}]13,13) rectangle ([shift={(-0.5\pgflinewidth,-0.5\pgflinewidth)}]-13,-13);"
    for i in range(len(IsoGraph)):
        IsogenyGraph += r"\node[circle,draw=black,very thick,inner sep=4pt,minimum size=20pt] (v_%s) at (%s:11cm) {$%s$};" %(i,360/len(IsoGraph)*(len(IsoGraph)/4) *i+(360/len(IsoGraph)*(i//4)),IsoGraph[i][0]
            .j_invariant())
    #drawMAP
    for i in range(len(IsoGraph)):
        for j in range(1,len(IsoGraph[i])):
            if IsoGraph[i][j][1] > 0:
                if i == j-1:
                    IsogenyGraph += r"\draw[draw={rgb,255:red,150; green,%s; blue,%s}, very thick, ->] (v_%s) edge[out=90,in=45, loop] (v_%s);" %((i*20+20)%255,(i*50+20)%255,i,j-1)
                else:
                    if IsoGraph[i][j][1] > 1:
                        IsogenyGraph += r"\draw[draw={rgb,255:red,150; green,%s; blue,%s}, very thick, ->] (v_%s) edge[bend left=17] node[rectangle, draw={rgb,255:red,150; green,%s; blue,%s}, fill=yellow!15, midway]{$%s$} (v_%s);" %((i*20+20)%255,(i*50+20)%255,i,
                            (i*20+20)%255,(i*50+20)%255,
                            IsoGraph[i][j][1],j-1)
                    else:
                        IsogenyGraph += r"\draw[draw={rgb,255:red,150; green,%s; blue,%s}, very thick, ->] (v_%s) edge[bend left=17] (v_%s);" %((i*20+20)%255,(i*50+20)%255,i,j-1)

    IsogenyGraph += r"\end{tikzpicture}"
    IsogenyGraph = IsogenyGraph.replace('*',' \cdot ')    #Replaces bad typsetting * with \cdot
    print IsogenyGraph                                    #Prints tex code


#printLaTeXAdjencicyMatrix(IsoGraph)
#printLaTeXIsogenyGraph(IsoGraph)
#prettyPrintIsogenyGraph(IsoGraph)
