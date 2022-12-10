# Function to add data string to box structure
function parseLineBuild(line,allStacks)
    startValue = 2
    while (true)
        if ((startValue>length(line))||!occursin("[",line))
            return
        end

        currentLength = (startValue+2)/4
        if !(currentLength in keys(allStacks))
            allStacks[currentLength] = []
        end
        if (line[startValue]!=' ')
            allStacks[currentLength] = append!([line[startValue]],allStacks[currentLength])
        end

        startValue += 4
    end
end

# Function to read the character on top of each stack
function getOutputString(allStacks)
    outputString = ""
    startValue = 1
    while (true)
        if !(startValue in keys(allStacks))
            break
        end

        outputString = string(outputString,allStacks[startValue][end])
        startValue += 1
    end

    return outputString
end

# Part 1: move groups of boxes one by one using pop and push
function parseLineMove(line,allStacks)
    if (!occursin("move",line))
        return
    end

    splitString = split(line,' ')

    for moves in 1:parse(Int,splitString[2])
        push!(allStacks[parse(Int,splitString[6])],pop!(allStacks[parse(Int,splitString[4])]))
    end
end

# Part 2: move groups of boxes without altering order
function parseLineMoveAll(line,allStacks)
    if (!occursin("move",line))
        return
    end

    splitString = split(line,' ')

    itemLength = length(allStacks[parse(Int,splitString[6])])
    for moves in 1:parse(Int,splitString[2])
        insert!(allStacks[parse(Int,splitString[6])],itemLength+1,pop!(allStacks[parse(Int,splitString[4])]))
    end
end

function calculateEverything(filename,answer1=nothing,answer2=nothing)
    allStacks = Dict{Int,Any}()
    allStacksNew = nothing

    # build structure with all boxes
    open(filename) do file
        for line in eachline(file)
            parseLineBuild(line,allStacks)
        end
    end

    # make a copy because Julia is mostly pass-by-reference
    allStacksNew = deepcopy(allStacks)

    # perform moves in both structures using different logic
    open(filename) do file        
        for line in eachline(file)            
            parseLineMove(line,allStacks)
            parseLineMoveAll(line,allStacksNew)
        end
    end
    
    outputString = getOutputString(allStacks)
    print(string("\nThe top elements for the 9000 machine are: ",outputString))
    # validate answer 1
    if (!isnothing(answer1))
        @assert(outputString==answer1)
        print("\nFirst test passed!")
    end

    outputStringNew = getOutputString(allStacksNew)
    print(string("\nThe top elements for the 9001 machine are: ",outputStringNew))
    # validate answer 2
    if (!isnothing(answer2))
        @assert(outputStringNew==answer2)
        print("\nSecond test passed!")
    end
end

calculateEverything("Day5/Day5Test.txt","CMZ","MCD")
calculateEverything("Day5/Day5Input.txt")