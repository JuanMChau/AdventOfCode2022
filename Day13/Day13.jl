# Function to parse each line into structure
function parseLine(line,startValue,endValue,previousArray=nothing,verbose=false)  
    parsedContent = []

    i = startValue
    while (i<=endValue)
        indexOffset = 0
        if (line[i]=='[')
            if (verbose)
                print(string("\nOpenBracket at: ",i))
            end

            closingBracketIndex = 1
            while(closingBracketIndex!=0)
                indexOffset += 1
                if (line[i+indexOffset]=='[')
                    closingBracketIndex +=1
                elseif (line[i+indexOffset]==']')
                    closingBracketIndex -= 1
                end                
            end

            if (verbose)
                print(string("\nClosingBracket at: ",i+indexOffset))
                print(string("\nParsing remaining content: ",line[(i+1):(i+indexOffset-1)]))
            end

            parsedContent = parseLine(line,i+1,i+indexOffset-1,parsedContent,verbose)
        elseif ((line[i]==',')||(line[i]==']'))
            indexOffset = 1
        else
            indexOffset = 1
            while(((Int(line[i+indexOffset])-Int('0'))>=0)&&((Int(line[i+indexOffset])-Int('0'))<=9))
                indexOffset +=1
            end
            if (verbose)
                print(string("\nAttempting to parse number: ",line[i:(i+indexOffset-1)]," from positions ",i," ",i+indexOffset-1))
            end
            parsedContent = append!(parsedContent,[parse(Int,line[i:(i+indexOffset-1)])])
        end

        i += indexOffset
    end

    if (isnothing(previousArray))
        return parsedContent
    else
        if (verbose)
            print(string("\nAppending ",parsedContent," to ",previousArray))
        end
        previousArray = append!(previousArray,[parsedContent])
        return previousArray
    end
end

# Function to compare ordered lines
function compareLines(line1,line2,verbose=false)
    itemCounter = 1
    while (true)
        if ((itemCounter>length(line1))&&(itemCounter<=length(line2)))
            if (verbose)
                print(string("\nLeft side ran out of items, it's in order"))
            end
            return -1
        elseif ((itemCounter<=length(line1))&&(itemCounter>length(line2)))
            if (verbose)
                print(string("\nRight side ran out of items, it's not in order"))
            end
            return 1
        elseif ((itemCounter>length(line1))&&(itemCounter>length(line2)))
            return 0
        end

        value1 = line1[itemCounter]        
        value2 = line2[itemCounter]

        if (verbose)
            print(string("\nComparing: ",value1," and ",value2))
        end

        if ((typeof(value1)==Int)&&(typeof(value2)==Int))
            if (value1>value2)
                if (verbose)
                    print(string("\nLeft is higher, it's not in order"))
                end
                return 1
            elseif (value1<value2)
                if (verbose)
                    print(string("\nRight is higher, it's in order"))
                end
                return -1
            end
        elseif (typeof(value1)==Int)
            compareResult = compareLines([value1],value2)
            if (compareResult!=0)
                return compareResult
            end
        elseif (typeof(value2)==Int)
            compareResult = compareLines(value1,[value2])
            if (compareResult!=0)
                return compareResult
            end
        else
            compareResult = compareLines(value1,value2)
            if (compareResult!=0)
                return compareResult
            end
        end

        itemCounter +=1
    end

    return 0
end

# Function to get pairs in order
function calculateOrderedPairs(allLines,verbose=false)
    orderedPairSum = 0
    line1 = nothing
    line2 = nothing

    lineCounter = 0
    for line in allLines
        lineCounter += 1

        if (verbose)
            print(string("\nLine to parse: ",line))
        end

        if ((lineCounter%3)==1)
            line1 = parseLine(line,1,lastindex(line),nothing,verbose)
            if (verbose)
                print(string("\nLine 1: ",line1[1]))
            end
        elseif ((lineCounter%3)==2)
            line2 = parseLine(line,1,lastindex(line),nothing,verbose)
            if (verbose)
                print(string("\nLine 2: ",line2[1]))
            end
        else
            if (compareLines(line1[1],line2[1],verbose)==-1)
                if (verbose)
                    print(string("\nPair that is lower: ",floor(lineCounter/3)))
                end
                orderedPairSum += floor(lineCounter/3)
            end
        end
    end

    return orderedPairSum
end

# Function to insert packet in ordered array
function insertPacket(packetArray,packet,verbose=false)
    for i = 1:lastindex(packetArray)
        if (compareLines(packetArray[i],packet,verbose)>=0)
            packetArray = insert!(packetArray,i,packet)
            break
        end
    end

    packetArray = append!(packetArray,[packet])

    return packetArray
end

# Function to obtain all packets in order
function sortedPackages(allLines,verbose=false)
    packetArray = Array{Any,1}()

    lineCounter = 0
    for line in allLines
        lineCounter += 1

        if (lineCounter%3==0)
            continue
        end

        parsedLine = parseLine(line,1,lastindex(line),nothing,verbose)
        if (lastindex(packetArray)==0)
            packetArray = insert!(packetArray,1,parsedLine[1])
        else
            packetArray = insertPacket(packetArray,parsedLine[1])
        end
    end

    return packetArray
end

# Function to find packet with specific position
function findPacketPosition(orderedPackets,packet)
    packetCounter = 1

    for orderedPacket in orderedPackets
        if (compareLines(orderedPacket,packet)==0)
            return packetCounter
        end

        packetCounter += 1
    end

    return -1
end

# Calculate everything in one run
function calculateEverything(filename,answer1=nothing,answer2=nothing)
    totalPairs = 0
    orderedPackets = nothing

    open(filename) do file
        allLines = readlines(file)
        totalPairs = calculateOrderedPairs(allLines,false)
        orderedPackets = sortedPackages(allLines,false)
    end

    orderedPackets = insertPacket(orderedPackets,Array{Any,1}([Array{Any,1}([2])]))
    orderedPackets = insertPacket(orderedPackets,Array{Any,1}([Array{Any,1}([6])]))
    decodingKeyValue = findPacketPosition(orderedPackets,Array{Any,1}([Array{Any,1}([2])]))*
        findPacketPosition(orderedPackets,Array{Any,1}([Array{Any,1}([6])]))
    
    print(string("\nSum of pair positions that are in order: ",totalPairs))
    # validate answer 1
    if (!isnothing(answer1))
        @assert(totalPairs==answer1)
        print("\nFirst test passed!")
    end

    print(string("\nDecoder key value: ",decodingKeyValue))
    # validate answer 2
    if (!isnothing(answer2))
        @assert(decodingKeyValue==answer2)
        print("\nSecond test passed!")
    end
end

calculateEverything("Day13/Day13Test.txt",13,140)
calculateEverything("Day13/Day13Input.txt")