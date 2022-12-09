function calculateEverything(filename,answer1=nothing,answer2=nothing)
    allElves = Int64[]
    append!(allElves,0)

    # Just calculate each elf's output
    open(filename) do file
        for line in eachline(file)
            if line == ""
                append!(allElves,0)
            else
                allElves[lastindex(allElves)] += parse(Int64,line)
            end
        end
    end

    # Part 1: find elf with highest calories output    
    print(string("\nElf with highest output: ", findmax(allElves)))
    if (!isnothing(answer1))
        @assert(findmax(allElves)[1]==answer1)
        print("\nFirst test passed!")
    end

    # Part 2: find top 3 elves with highest calories output
    sortedElves = sort(allElves,rev=true)
    print(string("\nOutput for top 3 elves: ",sortedElves[1:3]))
    print(string("\nTotal calories sum: ",sum(sortedElves[1:3])))
    if (!isnothing(answer2))
        @assert(sum(sortedElves[1:3])==answer2)
        print("\nSecond test passed!")
    end
end

calculateEverything("Day1/Day1Test.txt",24000,45000)
calculateEverything("Day1/Day1Input.txt")