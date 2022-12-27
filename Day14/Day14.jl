# Structure to keep map organized
mutable struct Point
    x::Int
    y::Int
end

baseMapStructure = ['.']
floorStructure = ['#']
startingPoint = Point(500,0)

# Function to parse map from inputs
function parseSandMap(allLines)
    sandMap = ['+']

    topLeft = deepcopy(startingPoint)
    topRight = deepcopy(startingPoint)
    botLeft = deepcopy(startingPoint)
    botRight = deepcopy(startingPoint)

    lineCounter = 0
    for line in allLines
        lineCounter += 1
        # print(string("\nAttempting to parse line: ",lineCounter))
        coordinates = split(line," -> ")
        for i in 1:lastindex(coordinates)            
            coordData = split(coordinates[i],",")
            x = parse(Int,coordData[1])
            y = parse(Int,coordData[2])
            if (x<topLeft.x)
                # expand map towards the left
                while (x<topLeft.x)
                    sandMap = cat(repeat(baseMapStructure,size(sandMap,1),1),sandMap,dims=2)
                    topLeft.x -= 1
                    botLeft.x -= 1
                end
            elseif (x>botRight.x)
                # expand map towards the right
                while (x>botRight.x)
                    sandMap = cat(sandMap,repeat(baseMapStructure,size(sandMap,1),1),dims=2)
                    topRight.x += 1
                    botRight.x += 1
                end
            end
            
            if (y<topRight.y)
                # expand map towards top
                while (y<topRight.y)
                    sandMap = cat(repeat(baseMapStructure,1,size(sandMap,2)),sandMap,dims=1)
                    topRight.y -= 1
                    topLeft.y -= 1
                end
            elseif (y>botLeft.y)
                # expand map towards bottom
                while (y>botLeft.y)
                    sandMap = cat(sandMap,repeat(baseMapStructure,1,size(sandMap,2)),dims=1)
                    botRight.y += 1
                    botLeft.y += 1
                end
            end

            # print(string("\nMap size is ",size(sandMap)," coordinate parsed was ",coordData))

            if (i==1)
                continue
            end

            prevCoordData = split(coordinates[i-1],",")
            xprev = parse(Int,prevCoordData[1])
            yprev = parse(Int,prevCoordData[2])

            # print(string("\nDrawing line from: ",prevCoordData," to ",coordData))

            # populate lines that go in the X direction
            while (xprev!=x)
                sandMap[y+1,xprev-topLeft.x+1] = '#'
                if (xprev>x)
                    xprev -= 1
                else
                    xprev += 1
                end
            end
            # populate lines that go in the Y direction
            while (yprev!=y)
                sandMap[yprev+1,x-topLeft.x+1] = '#'
                if (yprev>y)
                    yprev -= 1
                else
                    yprev += 1
                end
            end
            # populate the next point
            sandMap[y+1,x-topLeft.x+1] = '#'
        end
    end

    return sandMap
end

# Function to expand the map with the true floor
function expandMap(sandMap)
    sandMap = cat(sandMap,repeat(baseMapStructure,1,size(sandMap,2)),dims=1)
    sandMap = cat(sandMap,repeat(floorStructure,1,size(sandMap,2)),dims=1)
    return sandMap
end

# Function to drop sand until it can't be done anymore
function floodMapWithSand(sandMap,hasFloor=false)
    startSpot = nothing
    
    for row in axes(sandMap,1)
        for column in axes(sandMap,2)
            if (sandMap[row,column]=='+')
                startSpot = Point(column,row)
            end
        end
    end

    while (true)
        newSand = deepcopy(startSpot)
        while (true)
            newSand.y += 1
            if (newSand.y>size(sandMap,1))
                return sandMap
            end

            if (newSand.x==2)
                newSand.x += 1
                startSpot.x += 1
                sandMap = cat(repeat(baseMapStructure,size(sandMap,1),1),sandMap,dims=2)
                if (hasFloor)
                    sandMap[end,1] = '#'
                end
            elseif (newSand.x==(size(sandMap,2)-1))
                sandMap = cat(sandMap,repeat(baseMapStructure,size(sandMap,1),1),dims=2)
                if (hasFloor)
                    sandMap[end,end] = '#'
                end
            end

            if (sandMap[newSand.y,newSand.x]=='.')
                continue
            elseif (sandMap[newSand.y,newSand.x-1]=='.')
                newSand.x -= 1
                continue
            elseif (sandMap[newSand.y,newSand.x+1]=='.')
                newSand.x += 1
                continue
            elseif (sandMap[newSand.y-1,newSand.x]=='+')
                sandMap[newSand.y-1,newSand.x] = 'o'
                return sandMap
            else
                sandMap[newSand.y-1,newSand.x] = 'o'
                break
            end
        end
    end
end

# Function to count sand spots that were filled by sand
function countSandSpots(sandMap)
    sandSpotCount = 0

    for row in axes(sandMap,1)
        for column in axes(sandMap,2)
            if (sandMap[row,column]=='o')
                sandSpotCount += 1
            end
        end
    end

    return sandSpotCount
end

# Calculate everything in one run
function calculateEverything(filename,answer1=nothing,answer2=nothing)
    sandMap = nothing
    trueSandMap = nothing

    open(filename) do file
        allLines = readlines(file)
        sandMap = parseSandMap(allLines)
        trueSandMap = expandMap(sandMap)
    end

    sandMap = floodMapWithSand(sandMap,false)
    sandSpots = countSandSpots(sandMap)

    print(string("\nTotal of sand blocks: ",sandSpots))
    # validate answer 1
    if (!isnothing(answer1))
        @assert(sandSpots==answer1)
        print("\nFirst test passed!")
    end

    trueSandMap = floodMapWithSand(trueSandMap,true)
    trueSandSpots = countSandSpots(trueSandMap)

    print(string("\nTrue total of sand blocks: ",trueSandSpots))
    # validate answer 2
    if (!isnothing(answer2))
        @assert(trueSandSpots==answer2)
        print("\nSecond test passed!")
    end
end

calculateEverything("Day14/Day14Test.txt",24,93)
calculateEverything("Day14/Day14Input.txt")