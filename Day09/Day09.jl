# Rope structure to control all params
mutable struct Rope
    bodyX::Array{Int,1}
    bodyY::Array{Int,1}
    sX::Int
    sY::Int

    function Rope(bodyX::Array{Int,1},bodyY::Array{Int,1},sX,sY)
        return new(bodyX,bodyY,sX,sY)
    end
end

# Function to displace rope X
function shiftByX(rope::Rope,value)
    for item in 2:lastindex(rope.bodyX)
        rope.bodyX[item] += value
    end

    return rope
end

# Function to displace rope Y
function shiftByY(rope::Rope,value)
    for item in 2:lastindex(rope.bodyY)
        rope.bodyY[item] += value
    end       

    return rope 
end

# Function to update rope tail
function updateTail(rope::Rope)
    for item in 2:lastindex(rope.bodyX)
        partialDistance = bodyDistance(rope,item)
        if (partialDistance>sqrt(2))
            distanceX = rope.bodyX[item-1]-rope.bodyX[item]
            if (abs(distanceX)>1)
                rope.bodyX[item] += distanceX/abs(distanceX)
                distanceY = rope.bodyY[item-1]-rope.bodyY[item]
                if (abs(distanceY)>1)
                    rope.bodyY[item] += distanceY/abs(distanceY)
                elseif (rope.bodyY[item]!=rope.bodyY[item-1])
                    rope.bodyY[item] = rope.bodyY[item-1]
                end
            end

            distanceY = rope.bodyY[item-1]-rope.bodyY[item]
            if (abs(distanceY)>1)
                rope.bodyY[item] += distanceY/abs(distanceY)
                distanceX = rope.bodyX[item-1]-rope.bodyX[item]
                if (abs(distanceX)>1)
                    rope.bodyX[item] += distanceX/abs(distanceX)
                elseif (rope.bodyX[item]!=rope.bodyX[item-1])
                    rope.bodyX[item] = rope.bodyX[item-1]
                end
            end
        end
    end

    return rope
end

# Base board structure
baseBoardStructure = cat(['.'],['.'],dims=3)

# Function to count all visited slots
function countVisited(board)
    totalVisited = 0

    for row in axes(board,1)
        for column in axes(board,2)
            if (board[row,column,2]=='#')
                totalVisited += 1
            end
        end
    end

    return totalVisited
end

# Function to remove/readd board state based on position
function removeOrReadd(board,rope::Rope,add::Bool)
    if (add)
        board[rope.sY,rope.sX,1] = 's'
        for item in 2:(length(rope.bodyX)-1)
            board[rope.bodyY[item],rope.bodyX[item],1] = Char('0'+item-1)
        end
        board[rope.bodyY[end],rope.bodyX[end],1] = 'T'
        board[rope.bodyY[1],rope.bodyX[1],1] = 'H'

        board[rope.bodyY[end],rope.bodyX[end],2] = '#'
    else
        board[rope.sY,rope.sX,1] = '.'
        for item in 1:length(rope.bodyX)
            board[rope.bodyY[item],rope.bodyX[item],1] = '.'
        end
    end

    return board
end

# Function to calculate distance between body limbs
function bodyDistance(rope::Rope,limbPosition)
    distanceX = rope.bodyX[limbPosition]-rope.bodyX[limbPosition-1]
    distanceY = rope.bodyY[limbPosition]-rope.bodyY[limbPosition-1]
    return sqrt(distanceX*distanceX+distanceY*distanceY)
end

# Function for the rope to take many steps in one direction
function ropeTakesStep(instruction,board,rope::Rope)
    splitString = split(instruction,' ')
    displaceValue = parse(Int,splitString[2])
    if (splitString[1]=="R")
        while (displaceValue>0)
            board = removeOrReadd(board,rope,false)
            # head dynamics - right
            if (size(board,2)==(rope.bodyX[1]))
                board = cat(board,repeat(baseBoardStructure,size(board,1),1),dims=2)
            end
            rope.bodyX[1] += 1
            rope = updateTail(rope)
            board = removeOrReadd(board,rope,true)
            displaceValue -=1
        end
    elseif (splitString[1]=="U")
        while (displaceValue>0)
            board = removeOrReadd(board,rope,false)            
            # head dynamics - up
            if (1==(rope.bodyY[1]))
                board = cat(repeat(baseBoardStructure,1,size(board,2)),board,dims=1)
                rope.sY += 1                
                rope = shiftByY(rope,1)
            else
                rope.bodyY[1] -= 1
            end
            rope = updateTail(rope)
            board = removeOrReadd(board,rope,true)
            displaceValue -=1
        end
    elseif (splitString[1]=="D")
        while (displaceValue>0)
            board = removeOrReadd(board,rope,false)
            # head dynamics - down
            if (size(board,1)==(rope.bodyY[1]))
                board = cat(board,repeat(baseBoardStructure,1,size(board,2)),dims=1)
            end
            rope.bodyY[1] += 1
            rope = updateTail(rope)
            board = removeOrReadd(board,rope,true)
            displaceValue -=1
        end
    else
        while (displaceValue>0)
            board = removeOrReadd(board,rope,false)
            # head dynamics - left
            if (1==(rope.bodyX[1]))
                board = cat(repeat(baseBoardStructure,size(board,1),1),board,dims=2)
                rope.sX += 1
                rope = shiftByX(rope,1)
            else
                rope.bodyX[1] -= 1
            end            
            rope = updateTail(rope)
            board = removeOrReadd(board,rope,true)
            displaceValue -=1
        end
    end

    return board
end

# Part 1: move a length 2 rope
function parseInstructionsTwo(allLines)
    board = cat(['s'],['1'],dims=3)
    rope = Rope([1,1],[1,1],1,1)

    for line in allLines
        board = ropeTakesStep(line,board,rope)
    end

    return board
end

# Part 2: move a length 10 rope
function parseInstructionsTen(allLines)
    board = cat(['s'],['1'],dims=3)
    rope = Rope([1,1,1,1,1,1,1,1,1,1],[1,1,1,1,1,1,1,1,1,1],1,1)

    for line in allLines
        board = ropeTakesStep(line,board,rope)
        # display(board)
    end

    return board
end

# Calculate everything in one run
function calculateEverything(filename,answer1=nothing,answer2=nothing)
    boardTwo = undef
    boardTen = undef

    open(filename) do file
        fileData = readlines(file)
        boardTwo = parseInstructionsTwo(fileData)
        boardTen = parseInstructionsTen(fileData)
    end

    visitedLocationsTwo = countVisited(boardTwo)
    print(string("\nTotal visited locations (L2): ",visitedLocationsTwo))
    # validate answer 1
    if (!isnothing(answer1))
        @assert(visitedLocationsTwo==answer1)
        print("\nFirst test passed!")
    end

    visitedLocationsTen = countVisited(boardTen)
    print(string("\nTotal visited locations (L10): ",visitedLocationsTen))
    # validate answer 2
    if (!isnothing(answer2))
        @assert(visitedLocationsTen==answer2)
        print("\nSecond test passed!")
    end
end

calculateEverything("Day09/Day09Test1.txt",13,1)
calculateEverything("Day09/Day09Test2.txt",nothing,36)
calculateEverything("Day09/Day09Input.txt")