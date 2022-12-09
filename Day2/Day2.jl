gameMap = Dict("A"=>Dict("X"=>4,"Y"=>8,"Z"=>3),"B"=>Dict("X"=>1,"Y"=>5,"Z"=>9),"C"=>Dict("X"=>7,"Y"=>2,"Z"=>6))

# Part 1: calculate score based on XYZ as RPS
function processGame(line)
    item1 = SubString(line,1,1)
    item2 = SubString(line,3,3)
    return gameMap[item1][item2]
end

victoryMap = Dict("A"=>Dict("X"=>3,"Y"=>4,"Z"=>8),"B"=>Dict("X"=>1,"Y"=>5,"Z"=>9),"C"=>Dict("X"=>2,"Y"=>6,"Z"=>7))

# Part 2: calculate score based on XYZ as Lose, Draw, Win
function processVictory(line)
    item1 = SubString(line,1,1)
    item2 = SubString(line,3,3)
    return victoryMap[item1][item2]
end

# Process both parts in one run
open("Day2/Day2Input.txt") do file
    gameOutput = 0
    victoryOutput = 0
    for line in eachline(file)
        gameOutput += processGame(line)
        victoryOutput += processVictory(line)
    end

    print(string("\nTotal score for XYZ as RPS: ",gameOutput))
    print(string("\nTotal score for XYZ as LDW: ",victoryOutput))
end