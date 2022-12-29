# Structure to save sensor-beacon pairs
mutable struct SensorBeacon
    xSensor::Int
    ySensor::Int
    xBeacon::Int
    yBeacon::Int
    manhDistance::Int

    function SensorBeacon(xSensor,ySensor,xBeacon,yBeacon)
        manhDistance = abs(xSensor-xBeacon)+abs(ySensor-yBeacon)
        return new(xSensor,ySensor,xBeacon,yBeacon,manhDistance)
    end
end

# Structure to define a line (y=m*x+b), slope = m, b = offset
struct SensorEdge
    slope::Int
    offset::Int

    function SensorEdge(sensorBeacon::SensorBeacon,directionX,directionY)
        slope = -directionY/directionX
        offset = sensorBeacon.ySensor-slope*sensorBeacon.xSensor+directionY*(1+sensorBeacon.manhDistance)
        return new(slope,offset)
    end
end

# Function to read all sensor-beacon pairs
function readSensorBeacon(allLines)
    allSensorBeacon = Array{SensorBeacon,1}()

    for line in allLines
        allValues = collect(eachmatch(r"-?[0-9]+",line))
        parsedValues = [x for x in map(x->parse(Int,x.match),allValues)]
        allSensorBeacon = append!(allSensorBeacon,[SensorBeacon(parsedValues[1],parsedValues[2],parsedValues[3],parsedValues[4])])
    end

    return allSensorBeacon
end

# Function to see how many checked slots are in a specific row
function findTakenSpots(allSensorBeacon::Array{SensorBeacon,1},yPosition)
    takenSpots = Array{Any,1}()
    beaconsX = Array{Int,1}()
    sensorsX = Array{Int,1}()

    numberOfSpots = 0

    for sensorBeacon in allSensorBeacon
        if ((sensorBeacon.ySensor==yPosition)&&!(sensorBeacon.xSensor in sensorsX))
            sensorsX = append!(sensorsX,[sensorBeacon.xSensor])
        end
        if ((sensorBeacon.yBeacon==yPosition)&&!(sensorBeacon.xBeacon in beaconsX))
            beaconsX = append!(beaconsX,[sensorBeacon.xBeacon])
        end

        distanceToY = abs(sensorBeacon.ySensor-yPosition)
        if (distanceToY>sensorBeacon.manhDistance)
            continue
        end

        xLeft = sensorBeacon.xSensor-sensorBeacon.manhDistance+distanceToY
        xRight = sensorBeacon.xSensor+sensorBeacon.manhDistance-distanceToY
        if (isempty(takenSpots))
            takenSpots = append!(takenSpots,[[xLeft,xRight]])
        else
            insertPosition = 1        
            for spots in takenSpots
                if (xRight<spots[1])
                    takenSpots = insert!(takenSpots,insertPosition,[xLeft,xRight])
                    break
                elseif (xRight<=spots[2])
                    if (xLeft<=spots[1])
                        takenSpots[insertPosition] = [xLeft,spots[2]]
                    end                    
                    break
                elseif (xLeft<=spots[1])
                    takenSpots[insertPosition] = [xLeft,xRight]
                    break
                elseif (xLeft<=spots[2])
                    takenSpots[insertPosition] = [spots[1],xRight]
                    break
                else
                    if (insertPosition==lastindex(takenSpots))
                        takenSpots = insert!(takenSpots,insertPosition+1,[xLeft,xRight])
                    end
                end
                insertPosition += 1
            end
        end
    end

    # attempt to merge spots
    spotCounter = lastindex(takenSpots)
    while (spotCounter>1)
        spotCounter -= 1
        currentSpot = takenSpots[spotCounter]
        lastSpot = takenSpots[spotCounter+1]

        if (currentSpot[2]>=lastSpot[1])
            takenSpots[spotCounter] = [min(currentSpot[1],lastSpot[1]),max(currentSpot[2],lastSpot[2])]
            splice!(takenSpots,spotCounter+1)
        end
    end

    # count number of spots
    for spots in takenSpots
        numberOfSpots += 1+spots[2]-spots[1]

        for beacon in beaconsX
            if ((beacon>=spots[1])&&(beacon<=spots[2]))
                numberOfSpots -= 1
            end
        end

        for sensor in sensorsX
            if ((sensor>=spots[1])&&(sensor<=spots[2]))        
                numberOfSpots -= 1
            end
        end
    end

    return numberOfSpots
end

# Function to detect crossings between allLines
function findLineCrossings(positiveLine::SensorEdge,negativeLine::SensorEdge)
    x::Int = floor((negativeLine.offset-positiveLine.offset)/2)
    y::Int = x+positiveLine.offset

    return [x,y]
end

# Function to see if a line intersection is validate
function checkValidIntersection(point::Array{Int,1},maxSize)
    return ((point[1]>=0)&&(point[1]<=maxSize)&&(point[2]>=0)&&(point[2]<=maxSize))
end

# Function to find the missing beacon position
function findMissingBeacon(allSensorBeacon::Array{SensorBeacon,1},maxSize)
    positiveSlopeLines = Array{SensorEdge,1}()
    negativeSlopeLines = Array{SensorEdge,1}()
    # find all positive and negative slope lines
    for sensorBeacon in allSensorBeacon
        botLeftLine = SensorEdge(sensorBeacon,-1,1)
        topRightLine = SensorEdge(sensorBeacon,1,-1)
        botRightLine = SensorEdge(sensorBeacon,1,1)
        topLeftLine = SensorEdge(sensorBeacon,-1,-1)

        positiveSlopeLines = append!(positiveSlopeLines,[botLeftLine])
        positiveSlopeLines = append!(positiveSlopeLines,[topRightLine])
        negativeSlopeLines = append!(negativeSlopeLines,[botRightLine])
        negativeSlopeLines = append!(negativeSlopeLines,[topLeftLine])
    end

    tempPSL = Dict{SensorEdge,Int}()
    tempNSL = Dict{SensorEdge,Int}()
    # count occurrences of each line
    for psl in positiveSlopeLines
        if (haskey(tempPSL,psl))
            tempPSL[psl] += 1
        else
            tempPSL[psl] = 1
        end
    end
    for nsl in negativeSlopeLines
        if (haskey(tempNSL,nsl))
            tempNSL[nsl] += 1
        else
            tempNSL[nsl] = 1
        end
    end

    positiveSlopeLines = [psl for psl in keys(tempPSL) if (tempPSL[psl]>1)]
    negativeSlopeLines = [nsl for nsl in keys(tempNSL) if (tempNSL[nsl]>1)]

    allLineCrossings = Array{Any,1}()
    # get all positive vs negative line crossings
    for positiveSlopeLine in positiveSlopeLines
        for negativeSlopeLine in negativeSlopeLines
            lineCrossing = findLineCrossings(positiveSlopeLine,negativeSlopeLine)
            if (checkValidIntersection(lineCrossing,maxSize))
                allLineCrossings = append!(allLineCrossings,[lineCrossing])
            end
        end
    end

    for lineCrossing in allLineCrossings
        for sensorBeacon in allSensorBeacon
            if ((abs(lineCrossing[1]-sensorBeacon.xSensor)+abs(lineCrossing[2]-sensorBeacon.ySensor))<=
                sensorBeacon.manhDistance)
                break
            elseif (sensorBeacon==allSensorBeacon[end])
                return lineCrossing
            end
        end
    end
end

# Calculate everything in one run
function calculateEverything(filename,rowNumber,maxSize,answer1=nothing,answer2=nothing)
    allSensorBeacon = nothing

    open(filename) do file
        allLines = readlines(file)
        allSensorBeacon = readSensorBeacon(allLines)
    end

    takenSpots = findTakenSpots(allSensorBeacon,rowNumber)

    print(string("\nTotal spots where beacon could not be: ",takenSpots))
    # validate answer 1
    if (!isnothing(answer1))
        @assert(takenSpots==answer1)
        print("\nFirst test passed!")
    end

    beaconLocation = findMissingBeacon(allSensorBeacon,maxSize)
    beaconFrequency = 4000000*beaconLocation[1]+beaconLocation[2]

    print(string("\nBeacon frequency: ",beaconFrequency))
    # validate answer 2
    if (!isnothing(answer2))
        @assert(beaconFrequency==answer2)
        print("\nSecond test passed!")
    end
end

calculateEverything("Day15/Day15Test.txt",10,20,26,56000011)
calculateEverything("Day15/Day15Input.txt",2000000,4000000)