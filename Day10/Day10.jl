# Function to return signal strenght if needed
function updateSignalStrength(cycleCounter,variableValue)
    output = 0

    if (((cycleCounter+20)%40)==0)
        output = cycleCounter*variableValue
    end

    return output
end

# Function to return character to be printedText
function getPrintedCharacter(cycleCounter,variableValue)
    output = '#'

    currentPosition = (cycleCounter%40)+1

    if ((currentPosition<(variableValue+1))||(currentPosition>(variableValue+3)))
        output = '.'
    end

    print(string("\n",cycleCounter," ",currentPosition," ",variableValue," ",output))

    if ((cycleCounter%40)==0)
        output = string(output,"\n")
    end

    return output
end

# Part 1: calculate total signal strength
function calculateSignalStrength(allLines)
    signalStrength = 0
    cycleCounter = 0
    variableValue = 1

    for line in allLines
        cycleCounter += 1
        signalStrength += updateSignalStrength(cycleCounter,variableValue)
        if (line=="noop")
            
        else
            splitString = split(line,' ')
            if (splitString[1]=="addx")
                cycleCounter += 1
                signalStrength += updateSignalStrength(cycleCounter,variableValue)
                variableValue += parse(Int,splitString[2])
            end
        end        
    end

    return signalStrength
end

# Part 2: get graphic output
function getGraphicOutput(allLines)
    graphicOutput = "\n"
    cycleCounter = 0
    variableValue = 1

    for line in allLines
        cycleCounter += 1
        graphicOutput = string(graphicOutput,getPrintedCharacter(cycleCounter,variableValue))

        if (line=="noop")

        else
            splitString = split(line,' ')
            if (splitString[1]=="addx")
                cycleCounter += 1
                graphicOutput = string(graphicOutput,getPrintedCharacter(cycleCounter,variableValue))
                variableValue += parse(Int,splitString[2])
            end
        end
    end

    return graphicOutput
end

# Calculate everything in one run
function calculateEverything(filename,answer1=nothing,answer2=nothing)
    signalStrength = 0
    printedText = "\n"

    open(filename) do file
        allLines = readlines(file)
        signalStrength = calculateSignalStrength(allLines)
        printedText = getGraphicOutput(allLines)
    end

    print(string("\nFinal signal strenght: ",signalStrength))
    # validate answer 1
    if (!isnothing(answer1))
        @assert(signalStrength==answer1)
        print("\nFirst test passed!")
    end

    print(string("\nFinal displayed output: ",printedText))    
    # validate answer 2
    if (!isnothing(answer2))
        print(answer2)
        # @assert(printedText==answer2)
        print("\nSecond test passed!")
    end
end

calculateEverything("Day10/Day10Test.txt",13140,string("\n##..##..##..##..##..##..##..##..##..##..",
    "\n###...###...###...###...###...###...###.","\n####....####....####....####....####....",
    "\n#####.....#####.....#####.....#####.....","\n######......######......######......####",
    "\n#######.......#######.......#######.....","\n"))
calculateEverything("Day10/Day10Input.txt")