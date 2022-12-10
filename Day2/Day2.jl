# Create initial structures to define victory points based on each game logic
gameMap = Dict("A"=>Dict("X"=>4,"Y"=>8,"Z"=>3),"B"=>Dict("X"=>1,"Y"=>5,"Z"=>9),"C"=>Dict("X"=>7,"Y"=>2,"Z"=>6))
victoryMap = Dict("A"=>Dict("X"=>3,"Y"=>4,"Z"=>8),"B"=>Dict("X"=>1,"Y"=>5,"Z"=>9),"C"=>Dict("X"=>2,"Y"=>6,"Z"=>7))

# Part 1: calculate score based on XYZ as RPS
function processGame(line)
    item1 = SubString(line,1,1)
    item2 = SubString(line,3,3)
    return gameMap[item1][item2]
end

# Part 2: calculate score based on XYZ as Lose, Draw, Win
function processVictory(line)
    item1 = SubString(line,1,1)
    item2 = SubString(line,3,3)
    return victoryMap[item1][item2]
end

# Calculate everything in one run
function calculateEverything(filename,answer1=nothing,answer2=nothing)    
    open(filename) do file
        gameOutput = 0
        victoryOutput = 0
        for line in eachline(file)
            gameOutput += processGame(line)
            victoryOutput += processVictory(line)
        end

        print(string("\nTotal score for XYZ as RPS: ",gameOutput))
        # validate answer 1
        if (!isnothing(answer1))
            @assert(gameOutput==answer1)
            print("\nFirst test passed!")
        end
        print(string("\nTotal score for XYZ as LDW: ",victoryOutput))
        # validate answer 2
        if (!isnothing(answer2))
            @assert(victoryOutput==answer2)
            print("\nSecond test passed!")
        end
    end
end

calculateEverything("Day2/Day2Test.txt",15,12)
calculateEverything("Day2/Day2Input.txt")