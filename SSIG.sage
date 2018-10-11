class IsogenyGraph:
    def __init__(self, degreeOfIsogenies, fieldSize, A, B):
        self.l = degreeOfIsogenies                                              # Degree l isogenies we are looking for: l should be a prime not p or some power of such.
        self.q = fieldSize                                                      # Field size
        self.A = A
        self.B = B

        z = var('z')                                                            # Defining variable
        F.<z> = GF(self.q, name='z')                                            # Createing field
        self.F = F                                                              # Defining field
        self.E_0 = EllipticCurve(self.F,[A,B])                                  # Define initial curve (that is the starting point from which the graph will be build)
        self.adjacencyMatrix = []                                               # Resulting which will contain all information of the isogeny graph
        self.adjacencyMatrix.append([self.E_0])                                 # Adds the initial node to the graph
        if self.E_0.is_ordinary():
            raise ValueError('The starting curve specified is an ordinary curve. The starting curve must be supersingular!')

    #---------END-OF-METHOD----------#

    def computeIsogenyGraph(self):
        counter = 0
        while counter < len(self.adjacencyMatrix):
            if counter % 10==0:
                print "PROGRESS: ", counter, " nodes computed"
            print self.adjacencyMatrix[counter][0]
            self.__computeAdjacentNodesAndEdges(self.adjacencyMatrix[counter][0], counter)
            counter = counter + 1
        print "COMPLETE: ", counter, " nodes computed"

    #---------END-OF-METHOD----------#

    def __computeAdjacentNodesAndEdges(self, E, itt):
        O = E(0)                                                               # Defiens origin as O
        listOfDegreeLTorsionPoints = O.division_points(self.l)                 # The torsion-l points

        # Creating cyclic groups:
        listOfAllCyclicGroups = []
        for i in range(len(listOfDegreeLTorsionPoints)):
            if not listOfDegreeLTorsionPoints[i] == O:                         # Remove identity point
                setOfCyclicGroupElements = []                                                   # Creates a list contaning elements of the given cyclic group
                for j in range(1,self.l):
                    setOfCyclicGroupElements.append(j*listOfDegreeLTorsionPoints[i])
                listOfAllCyclicGroups.append(setOfCyclicGroupElements)                          # Adds the cyclic group to the list of cyclic groups of order l

        # Remove dublicate cyclic groups:
        setOfCyclicGroups = []
        setOfCyclicGroups.append(listOfAllCyclicGroups[0])                     # initiate list
        for i in range(1,len(listOfAllCyclicGroups)):
            allready_defined = false
            for j in range(len(setOfCyclicGroups)):
                for k in range(len(setOfCyclicGroups[j])):
                    if (listOfAllCyclicGroups[i])[0] == (setOfCyclicGroups[j])[k]:
                        allready_defined = true
            if not allready_defined:
                setOfCyclicGroups.append(listOfAllCyclicGroups[i])

        for j in range(len(self.adjacencyMatrix)):                             # Persisting Iso list
            self.adjacencyMatrix[itt].append([self.adjacencyMatrix[j][0],0])

        #Find all degree l isogenies from our curve E:
        for i in range(len(setOfCyclicGroups)):
            Q = setOfCyclicGroups[i][0]                                        # Get generator Q of subgroup
            phi = E.isogeny(Q)                                                 # Creates phi : E --> E/<Q>=E2
            E2 = phi.codomain()                                                # Get image of phi
            E2j = E2.j_invariant()                                             # To simplify
            inList = false
            for j in range(len(self.adjacencyMatrix)):                         #Checks if we have already found and put the node in our graph
                if E2j == self.adjacencyMatrix[j][0].j_invariant():
                    inList = true
            if not inList:                                                     #If the node is not in our graph... well, put it there!
                self.adjacencyMatrix.append([E2])
                for k in range(itt+1):                                         #Since we have found a new node lets update our graph edges
                    self.adjacencyMatrix[k].append([E2,0])                     #Non of our previous found nodes hand an edge to our new node, so the number of edges is set to zero.

            # Update the edges of our node E:
            for j in range(1,len(self.adjacencyMatrix[itt])):                  #Traverse through all known nodes in the list to find E2
                if self.adjacencyMatrix[itt][j][0].j_invariant() == E2j:
                    self.adjacencyMatrix[itt][j].append(Q)                     #Add the kernel generating element to recreate the isogeny
                    self.adjacencyMatrix[itt][j][1] = self.adjacencyMatrix[itt][j][1] + 1 #Increment the number of edges from E to E2

    #---------END-OF-METHOD----------#

    def printLaTeXAdjencicyMatrix(self):
        """
        Creates an latex formatted adjencicy matrix
        """
        IsoGraph = self.adjacencyMatrix

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

    #---------END-OF-METHOD----------#
    
    #Creates a latex formatted isogeny graph drawn in tikz
    def printLaTeXIsogenyGraph():

        IsoGraph = self.adjacencyMatrix

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
    #---------END-OF-METHOD----------#

    def prettyPrintIsogenyGraph(self):
        """
        This ONLY works for graphs of SIZE divisible by 4!!!!!!
        """

        IsoGraph = self.adjacencyMatrix

        IsogenyGraph = r"\begin{tikzpicture}[rotate=12] \draw [fill=yellow!15,rounded corners, draw=black!50, dashed, rotate=-12] ([shift={(0.5\pgflinewidth,0.5\pgflinewidth)}]13,13) rectangle ([shift={(-0.5\pgflinewidth,-0.5\pgflinewidth)}]-13,-13);"
        for i in range(len(IsoGraph)):
            IsogenyGraph += r"\node[circle,draw=black,very thick,inner sep=4pt,minimum size=20pt] (v_%s) at (%s:11cm) {$%s$};" %(i,360/len(IsoGraph)*(len(IsoGraph)/4) *i+(360/len(IsoGraph)*(i//4)),IsoGraph[i][0].j_invariant())
        #drawMAP
        for i in range(len(IsoGraph)):
            for j in range(1,len(IsoGraph[i])):
                if IsoGraph[i][j][1] > 0:
                    if i == j-1:
                        if IsoGraph[i][j][1] > 1:
                            IsogenyGraph += r"\draw[draw={rgb,255:red,150; green,%s; blue,%s}, very thick, ->] (v_%s) edge[out=90,in=45, loop] node[rectangle, draw={rgb,255:red,150; green,%s; blue,%s}, fill=yellow!15, midway] {$%s$} (v_%s);" %((i*20+20)%255,(i*50+20)%255,i,(i*20+20)%255,(i*50+20)%255,IsoGraph[i][j][1],j-1)
                        else:
                            IsogenyGraph += r"\draw[draw={rgb,255:red,150; green,%s; blue,%s}, very thick, ->] (v_%s) edge[out=90,in=45, loop] (v_%s);" %((i*20+20)%255,(i*50+20)%255,i,j-1)
                    else:
                        if IsoGraph[i][j][1] > 1:
                            if ((360/len(IsoGraph)*(len(IsoGraph)/4)*i+(360/len(IsoGraph)*(i//4)))-(360/len(IsoGraph)*(len(IsoGraph)/4)*j+(360/len(IsoGraph)*(j//4))))<0:
                                IsogenyGraph += r"\draw[draw={rgb,255:red,150; green,%s; blue,%s}, very thick, ->] (v_%s) edge[bend left=17] node[rectangle, draw={rgb,255:red,150; green,%s; blue,%s}, fill=yellow!15, midway]{$%s$} (v_%s);" %((i*20+20)%255,(i*50+20)%255,i,(i*20+20)%255,(i*50+20)%255,IsoGraph[i][j][1],j-1)
                            else:
                                IsogenyGraph += r"\draw[draw={rgb,255:red,150; green,%s; blue,%s}, very thick, ->] (v_%s) edge[bend right=17] node[rectangle, draw={rgb,255:red,150; green,%s; blue,%s}, fill=yellow!15, midway]{$%s$} (v_%s);" %((i*20+20)%255,(i*50+20)%255,i,(i*20+20)%255,(i*50+20)%255,IsoGraph[i][j][1],j-1)
                        else:
                            IsogenyGraph += r"\draw[draw={rgb,255:red,150; green,%s; blue,%s}, very thick, ->] (v_%s) edge[bend left=17] (v_%s);" %((i*20+20)%255,(i*50+20)%255,i,j-1)

        IsogenyGraph += r"\end{tikzpicture}"
        IsogenyGraph = IsogenyGraph.replace('*',' \cdot ')
        print IsogenyGraph                                    #Prints tex code

        #---------END-OF-METHOD----------#
#---------END-OF-CLASS----------#


# ==== EXAMPLE ==== #
myIsogenyGraph = IsogenyGraph(3,(83)^2,0,1)     # Degree 3 isogeny graph with starting curve y^2  = x^3 + 1 defined over a field of size (83)^2
myIsogenyGraph.computeIsogenyGraph()            # This should allways be run in order to acctually compute the graph
myIsogenyGraph.printLaTeXAdjencicyMatrix()      # Prints out a LaTeX formatted adjencicy matrix
myIsogenyGraph.prettyPrintIsogenyGraph()        # Prints out a LaTeX formatted Graph (WARNING! this only works for graphs divisible by 4. Please be sure to use printLaTeXIsogenyGraph() for the general purpose)

#==============#
# Nice To Know #
#==============#
# myIsogenyGraph.F.modulus()                                                          # Prints the irreducible polynomial of the field
# print "Field myIsogenyGraph.F defined as Z_",83,"[x]/<",myIsogenyGraph.F.modulus(),">"
# myIsogenyGraph.E_0.cardinality()                                                     # Get cardinality (of the initial 'node' ~curve )
# myIsogenyGraph.E_0.j_invariant()                                                     # Get i invariant (of the initial 'node' ~curve )
