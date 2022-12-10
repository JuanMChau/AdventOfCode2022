# Function to see if all characters are different
function checkAllDifferent(substring)
    allCharacters = []
    for character in substring
        if (character in allCharacters)
            return false
        end
        append!(allCharacters,character)
    end
    return true
end

# Function to find the final position of a marker
function findEndMarker(line,numberOfCharacters)
    markerPosition = numberOfCharacters
    while (true)
        if (checkAllDifferent(line[(markerPosition-numberOfCharacters+1):markerPosition]))
            break
        end

        markerPosition += 1
    end

    return markerPosition
end

# Calculate everything in one run
function calculateEverything(filename,answer1=nothing,answer2=nothing)
    open(filename) do file
        markerPosition = 0
        messagePosition = 0
        for line in readlines(file)
            # Part 1: find position of marker (end)
            markerPosition = findEndMarker(line,4)
            # Part 2: find position of message (end)
            messagePosition = findEndMarker(line,14)
        end

        print(string("\nThe final position of the marker is: ",markerPosition))
        # validate answer 1
        if (!isnothing(answer1))
            @assert(markerPosition==answer1)
            print("\nFirst test passed!")
        end

        print(string("\nThe final position of the message is: ",messagePosition))
        # validate answer 2
        if (!isnothing(answer2))
            @assert(messagePosition==answer2)
            print("\nSecond test passed!")
        end
    end
end

calculateEverything("Day6/Day6Test.txt",7,19)
calculateEverything("Day6/Day6Input.txt")