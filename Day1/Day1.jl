allElves = Int64[]
append!(allElves,0)

# Just calculate each elf's output
open("Day1/Day1Input.txt") do file
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

# Part 2: find top 3 elves with highest calories output
sortedElves = sort(allElves,rev=true)
print(string("\nOutput for top 3 elves: ",sortedElves[1:3]))
print(string("\nTotal calories sum: ",sum(sortedElves[1:3])))