# Function to read the map
function readMapDirect(allLines)
    map = Array{Any}(undef,length(allLines[1]),length(allLines),3)

    lineCounter = 0
    for line in allLines
        lineCounter += 1
        characterCounter = 0
        for character in line
            characterCounter += 1
            if (character=='S')
                map[characterCounter,lineCounter,1] = 0
                map[characterCounter,lineCounter,3] = 1
            elseif (character=='E')
                map[characterCounter,lineCounter,1] = Int('z')-Int('a')
            else
                map[characterCounter,lineCounter,1] = Int(character)-Int('a')
            end
            map[characterCounter,lineCounter,2] = character
        end
    end

    return map
end

# Function to read the map inversely
function readMapInverse(allLines)
    map = Array{Any}(undef,length(allLines[1]),length(allLines),3)

    lineCounter = 0
    for line in allLines
        lineCounter += 1
        characterCounter = 0
        for character in line
            characterCounter += 1
            if (character=='S')
                map[characterCounter,lineCounter,1] = Int('z')-Int('a')                
            elseif (character=='E')
                map[characterCounter,lineCounter,1] = 0
                map[characterCounter,lineCounter,3] = 1
            else
                map[characterCounter,lineCounter,1] = Int('z')-Int(character)
            end
            map[characterCounter,lineCounter,2] = character
        end
    end

    return map
end

# Function to find start/end position
function findPosition(map::Array{Any,3},character)
    for row in axes(map,1)
        for column in axes(map,2)
            if (map[row,column,2]==character)
                return [column,row]
            end
        end
    end
end

# Function to get map height
function getHeight(map::Array{Any,3},node::Array{Int,1})
    return map[node[2],node[1],1]
end

# Function to expand node
function canTakeStep(map::Array{Any,3},fromNode::Array{Int,1},toNode::Array{Int,1})
    # check border conditions
    if ((toNode[1]<1)||(toNode[1]>size(map,2))||(toNode[2]<1)||(toNode[2]>size(map,1)))
        return false        
    end 
    
    # check height conditions
    if ((getHeight(map,toNode)-getHeight(map,fromNode))>1)
        return false
    end

    # check movement conditions
    if (isassigned(map,toNode[2],toNode[1],3)&&(map[toNode[2],toNode[1],3]<map[fromNode[2],fromNode[1],3]))
        return false
    end

    return true
end

# Function to remove duplicate nodes and add a new one
function removeDuplicatesAndAdd(nodeList::Array{Any,1},node::Array{Int,1})
    foundLower = false

    for i = length(nodeList):-1:1
        nodeToCompare = nodeList[i]
        if ((nodeToCompare[1]==node[1])&&(nodeToCompare[2]==node[2]))
            if (nodeToCompare[3]>=node[3])
                splice!(nodeList,i)
            else
                foundLower = true
            end
        end
    end

    if (!foundLower)
        append!(nodeList,[node])
    end

    return nodeList
end

# Function to run A star algorithm
function runAStar(map,startPosition)    
    expandedNodes = Array{Any,1}()
    append!(expandedNodes,[append!(startPosition,[getHeight(map,startPosition)])])

    nodeCount = 1

    while (!isempty(expandedNodes))
        currentNode = splice!(expandedNodes,1)

        # check left node
        if (canTakeStep(map,currentNode,currentNode+[-1,0,1]))
            newNode = currentNode+[-1,0,1]
            map[newNode[2],newNode[1],3] = newNode[3]
            expandedNodes = removeDuplicatesAndAdd(expandedNodes,newNode)
        end

        # check right node
        if (canTakeStep(map,currentNode,currentNode+[1,0,1]))
            newNode = currentNode+[1,0,1]
            map[newNode[2],newNode[1],3] = newNode[3]
            expandedNodes = removeDuplicatesAndAdd(expandedNodes,newNode)
        end

        # check up node
        if (canTakeStep(map,currentNode,currentNode+[0,-1,1]))
            newNode = currentNode+[0,-1,1]
            map[newNode[2],newNode[1],3] = newNode[3]
            expandedNodes = removeDuplicatesAndAdd(expandedNodes,newNode)
        end

        # check down node
        if (canTakeStep(map,currentNode,currentNode+[0,1,1]))
            newNode = currentNode+[0,1,1]
            map[newNode[2],newNode[1],3] = newNode[3]
            expandedNodes = removeDuplicatesAndAdd(expandedNodes,newNode)
        end
    end
    
    return map
end

# Function to find the lowest amount of steps to one specific character
function findLowestSteps(map,character)
    desiredPosition = [0,0,length(map)]

    for row in axes(map,1)
        for column in axes(map,2)
            if (!isassigned(map,row,column,3))
                continue
            end

            if ((map[row,column,2]==character)&&(map[row,column,3]<desiredPosition[3]))
                desiredPosition[1] = column
                desiredPosition[2] = row
                desiredPosition[3] = map[row,column,3]
            end
        end
    end

    return desiredPosition[3]
end

# Calculate everything in one run
function calculateEverything(filename,answer1=nothing,answer2=nothing)
    minSteps = 0
    minStepsRev = 0

    open(filename) do file
        fileContent = readlines(file)
        mapDirect = readMapDirect(fileContent)        
        startPosition = findPosition(mapDirect,'S')
        endPosition = findPosition(mapDirect,'E')

        mapDirect = runAStar(mapDirect,startPosition)
        minSteps = mapDirect[endPosition[2],endPosition[1],3]

        # display(mapDirect)

        mapReverse = readMapInverse(fileContent)
        mapReverse = runAStar(mapReverse,endPosition)
        minStepsRev = findLowestSteps(mapReverse,'a')
    end
    
    print(string("\nMinimum steps to make it from S to E: ",minSteps))
    # validate answer 1
    if (!isnothing(answer1))
        @assert(minSteps==answer1)
        print("\nFirst test passed!")
    end

    print(string("\nMinimum steps to find an a from E: ",minStepsRev))
    # validate answer 2
    if (!isnothing(answer2))
        @assert(minStepsRev==answer2)
        print("\nSecond test passed!")
    end
end

calculateEverything("Day12/Day12Test.txt",31,29)
calculateEverything("Day12/Day12Input.txt")