# Tree structure
mutable struct FileOrFolder
    name::String
    totalSize::Int
    children::Dict{String,FileOrFolder}
    parent::FileOrFolder
    function FileOrFolder(name,totalSize)
        return new(name,totalSize)
    end
end

# Function to create a directory inside the tree
function makeDir(dirName,isFolder,parent)
    newDir = FileOrFolder(dirName,0)
    if (isFolder)
        newDir.children = Dict{String,FileOrFolder}()
    end
    if (!isnothing(parent))
        newDir.parent = parent
    end
    return newDir
end

# Function to create a file inside the tree
function makeFile(fileName,size,parent)
    newFile = FileOrFolder(fileName,size)
    if (!isnothing(parent))
        newFile.parent = parent
    end
    return newFile
end

# Function to recalculate the folder sizes
function depthFirstFileSize(entryPoint)
    if (isdefined(entryPoint,:children))
        tempSize = 0
        for child in keys(entryPoint.children)
            tempSize += depthFirstFileSize(entryPoint.children[child])
        end
        entryPoint.totalSize = tempSize
    end
    return entryPoint.totalSize
end

# Function to create tree from text file
function parseFile(allLines,linePosition,currentLocation)
    while (linePosition<=length(allLines))
        splitString = split(allLines[linePosition],' ')
        if (splitString[1]=="\$")
            if (splitString[2]=="cd")
                if (splitString[3]=="..")
                    currentLocation = currentLocation.parent
                else
                    currentLocation = currentLocation.children[splitString[3]]
                end
            elseif (splitString[2]=="ls")
                while (true)
                    linePosition += 1
                    if (linePosition>length(allLines))
                        break
                    end

                    tempSplitString = split(allLines[linePosition],' ')
                    if (tempSplitString[1]=="\$")
                        linePosition -=1
                        break
                    elseif (tempSplitString[1]=="dir")
                        currentLocation.children[tempSplitString[2]] = makeDir(tempSplitString[2],true,currentLocation)
                    else
                        currentLocation.children[tempSplitString[2]] = makeFile(tempSplitString[2],parse(Int,tempSplitString[1]),currentLocation)
                    end
                end
            end
        end
        
        linePosition +=1
    end
end

# Part 1: find all files/folders with size up to n (with repetition)
function depthFirstFindSizeUnder(entryPoint,maxSize,totalSize)
    if (isdefined(entryPoint,:children))
        if (entryPoint.totalSize<=maxSize)
            totalSize += entryPoint.totalSize
        end

        for child in keys(entryPoint.children)
            totalSize = depthFirstFindSizeUnder(entryPoint.children[child],maxSize,totalSize)
        end
    end

    return totalSize
end

# Part 2: find the smallest folder to be deleted
function depthFirstFindSmallestFolder(entryPoint,minSizeToDelete,maxSize)
    if (isdefined(entryPoint,:children))
        for child in keys(entryPoint.children)
            testMinSize = depthFirstFindSmallestFolder(entryPoint.children[child],minSizeToDelete,maxSize)
            if ((testMinSize<maxSize)&&(testMinSize>minSizeToDelete))
                maxSize = testMinSize
            elseif (isdefined(entryPoint.children[child],:children)&&(entryPoint.children[child].totalSize<maxSize)&&
                (entryPoint.children[child].totalSize>minSizeToDelete))
                maxSize = entryPoint.children[child].totalSize
            end
        end
    end

    return maxSize
end

# Calculate everything in one run
function calculateEverything(filename,answer1=nothing,answer2=nothing)
    entryPoint = makeDir("/",true,nothing)
    currentLocation = entryPoint
    open(filename) do file
        allLines = readlines(file)
        linePosition = 2
        parseFile(allLines,linePosition,currentLocation)
        depthFirstFileSize(entryPoint)
    end

    totalSize = depthFirstFindSizeUnder(entryPoint,100000,0)
    print(string("\nSum of folder sizes that meet the condition: ",totalSize))
    # validate answer 1
    if (!isnothing(answer1))
        @assert(totalSize==answer1)
        print("\nFirst test passed!")
    end

    minSizeToDelete = entryPoint.totalSize-(70000000-30000000)
    sizeToDelete = depthFirstFindSmallestFolder(entryPoint,minSizeToDelete,entryPoint.totalSize)
    print(string("\nSize of folder to be deleted: ",sizeToDelete))
    # validate answer 2
    if (!isnothing(answer2))
        @assert(sizeToDelete==answer2)
        print("\nSecond test passed!")
    end
end

calculateEverything("Day07/Day07Test.txt",95437,24933642)
calculateEverything("Day07/Day07Input.txt")