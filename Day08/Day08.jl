# Function to read the matrix in one go
function readMatrix(allLines)
    treeMatrix = []
    for line in allLines
        tempRow = []
        for tree in line
            append!(tempRow,[parse(Int,tree)])
        end
        treeMatrix = vcat(treeMatrix,tempRow)
    end

    return reshape(treeMatrix,(length(allLines),length(allLines[1])))
end

# Function to see if a tree is visible from one direction
function checkTreeDirection(treeMatrix,i,j,directionX,directionY,threshX,threshY)
    value = treeMatrix[i,j]
    while (((directionX==0)||(((i-threshX)*directionX)<0))&&
        ((directionY==0)||(((j-threshY)*directionY)<0)))
        i += directionX
        j += directionY
        if (value<=treeMatrix[i,j])
            return false
        end
    end
    return true
end

# Function to check if a tree is visible
function isTreeVisible(treeMatrix,i,j,maxX,maxY)
    return (checkTreeDirection(treeMatrix,i,j,1,0,maxX,-1)||checkTreeDirection(treeMatrix,i,j,-1,0,1,-1)||
        checkTreeDirection(treeMatrix,i,j,0,1,-1,maxY)||checkTreeDirection(treeMatrix,i,j,0,-1,-1,1))
end

# Part 1: calculate visible trees from the sides
function findVisibleTrees(treeMatrix)
    visibleTrees = 2*size(treeMatrix,1)+2*size(treeMatrix,2)-4

    for i in 2:(size(treeMatrix,1)-1)
        for j in 2:(size(treeMatrix,2)-1)
            if (isTreeVisible(treeMatrix,i,j,size(treeMatrix,1),size(treeMatrix,2)))
                visibleTrees += 1
            end
        end
    end

    return visibleTrees
end

# Function to get visible trees in one direction
function getVisibleTrees(treeMatrix,i,j,directionX,directionY,threshX,threshY)
    visibleTrees = 0
    value = treeMatrix[i,j]

    while (((directionX==0)||(((i-threshX)*directionX)<0))&&
        ((directionY==0)||(((j-threshY)*directionY)<0)))
        visibleTrees += 1
        i += directionX
        j += directionY
        if (value<=treeMatrix[i,j])
            break
        end
    end

    return visibleTrees
end

# Part 2: calculate scenic score from visible trees
function findScenicScore(treeMatrix)
    scenicScore = 0

    for i in 2:(size(treeMatrix,1)-1)
        for j in 2:(size(treeMatrix,2)-1)
            tempScenicScore = (getVisibleTrees(treeMatrix,i,j,1,0,size(treeMatrix,1),-1)*getVisibleTrees(treeMatrix,i,j,-1,0,1,-1)*
                getVisibleTrees(treeMatrix,i,j,0,1,-1,size(treeMatrix,2))*getVisibleTrees(treeMatrix,i,j,0,-1,-1,1))
            if (scenicScore<tempScenicScore)
                scenicScore = tempScenicScore
            end
        end
    end    

    return scenicScore
end

# Calculate everything in one run
function calculateEverything(filename,answer1=nothing,answer2=nothing)
    treeMatrix = nothing
    open(filename) do file
        treeMatrix = readMatrix(readlines(file))
    end

    visibleTrees = findVisibleTrees(treeMatrix)
    print(string("\nTotal visible trees from the edges: ",visibleTrees))
    # validate answer 1
    if (!isnothing(answer1))
        @assert(visibleTrees==answer1)
        print("\nFirst test passed!")
    end

    scenicScore = findScenicScore(treeMatrix)
    print(string("\nMaximum scenic score: ",scenicScore))
    # validate answer 2
    if (!isnothing(answer2))
        @assert(scenicScore==answer2)
        print("\nSecond test passed!")
    end
end

calculateEverything("Day08/Day08Test.txt",21,8)
calculateEverything("Day08/Day08Input.txt")