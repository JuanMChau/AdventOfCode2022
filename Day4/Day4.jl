mutable struct doubleShifts
    elf1Start::Int
    elf1End::Int
    elf2Start::Int
    elf2End::Int
end

function splitString(string,separators)
    firstSeparation = split(string,separators[1])
    elf1 = split(firstSeparation[1],separators[2])
    elf2 = split(firstSeparation[2],separators[2])
    return doubleShifts(parse(Int,elf1[1]),parse(Int,elf1[2]),parse(Int,elf2[1]),parse(Int,elf2[2]))
end

# Part 1: calculate fully overlapped shifts
function calculateContainedOverlap(parsedShifts)
    return (((parsedShifts.elf1Start>=parsedShifts.elf2Start)&&(parsedShifts.elf1End<=parsedShifts.elf2End))||
        ((parsedShifts.elf1Start<=parsedShifts.elf2Start)&&(parsedShifts.elf1End>=parsedShifts.elf2End)))
end

# Part 2: calculate partially overlapped shifts
function calculatePartialOverlap(parsedShifts)
    return (((parsedShifts.elf1Start<=parsedShifts.elf2Start)&&(parsedShifts.elf1End>=parsedShifts.elf2Start))||
        ((parsedShifts.elf1Start<=parsedShifts.elf2End)&&(parsedShifts.elf1End>=parsedShifts.elf2End))||
        ((parsedShifts.elf2Start<=parsedShifts.elf1Start)&&(parsedShifts.elf2End>=parsedShifts.elf1Start))||
        ((parsedShifts.elf2Start<=parsedShifts.elf1End)&&(parsedShifts.elf2End>=parsedShifts.elf1End)))
end

function calculateEverything(filename,answer1=nothing,answer2=nothing)
    # Just calculate each overlapping pair of shifts
    fullyOverlappedShifts = 0
    partiallyOverlappedShifts = 0
    open(filename) do file
        for line in eachline(file)
            parsedShifts = splitString(line,",-")
            fullyOverlappedShifts += calculateContainedOverlap(parsedShifts)
            partiallyOverlappedShifts += calculatePartialOverlap(parsedShifts)
        end
    end
    
    print(string("\nNumber of fully contained shifts: ",fullyOverlappedShifts))
    if (!isnothing(answer1))
        @assert(fullyOverlappedShifts==answer1)
        print("\nFirst test passed!")
    end

    print(string("\nNumber of partially contained shifts: ",partiallyOverlappedShifts))
    if (!isnothing(answer2))
        @assert(partiallyOverlappedShifts==answer2)
        print("\nSecond test passed!")
    end
end

calculateEverything("Day4/Day4Test.txt",2,4)
calculateEverything("Day4/Day4Input.txt")