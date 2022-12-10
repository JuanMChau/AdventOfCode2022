
# Function to find priority value for common character
function processCommonCharacter(commonCharacter)
    if (Int(commonCharacter) > Int('Z'))
        return Int(commonCharacter)-Int('a')+1
    else
        return Int(commonCharacter)-Int('A')+27
    end
end

# Function to find common characters between two strings
function processBag(string1,string2)
    allItemsRucksack1 = Dict{Char,Any}()
    output = ""

    for character in string1
        if !(character in keys(allItemsRucksack1))
            merge!(allItemsRucksack1,Dict(character=>1))
        else
            allItemsRucksack1[character] +=1
        end
    end
    for character in string2        
        if (character in keys(allItemsRucksack1))
            output = string(output,character)
        end
    end

    return output
end

# Calculate everything in one run
function calculateEverything(filename,answer1=nothing,answer2=nothing)
    open(filename) do file
        totalPriority = 0
        line1 = ""
        line2 = ""
        line3 = ""
        counter = 0
        groupedPriority = 0
        
        for line in eachline(file)
            # Part 1: find common element in both of each rucksack's halves
            item1 = SubString(line,1,Int(0.5*length(line)))
            item2 = SubString(line,Int(1+length(line)*0.5),length(line))
            commonCharacter = processBag(item1,item2)
            totalPriority += processCommonCharacter(commonCharacter[1])

            # Part 2: find common element between groups of 3 rucksacks
            line1 = line2
            line2 = line3
            line3 = line
            counter += 1
            if (counter==3)
                counter = 0
                commonLine12 = processBag(line1,line2)
                commonLine123 = processBag(commonLine12,line3)
                groupedPriority += processCommonCharacter(commonLine123[1])
            end
        end

        print(string("\nTotal priority of common items in each rucksack: ",totalPriority))
        # validate answer 1
        if (!isnothing(answer1))
            @assert(totalPriority==answer1)
            print("\nFirst test passed!")
        end

        print(string("\nTotal grouped priority for 3 rucksacks: ",groupedPriority))
        # validate answer 2
        if (!isnothing(answer2))
            @assert(groupedPriority==answer2)
            print("\nSecond test passed!")
        end
    end
end

calculateEverything("Day03/Day03Test.txt",157,70)
calculateEverything("Day03/Day03Input.txt")
