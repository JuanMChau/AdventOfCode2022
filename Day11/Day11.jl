# Monkey structure for the exercise
mutable struct Monkey
    items::Array{Any,1}
    operator::Char
    operationValuePre::String
    operationValuePost::String
    testValue::Int
    nextMonkeyTrue::Int
    nextMonkeyFalse::Int
    totalInspections::Int
end

bigIntThreshold = 10000000

# Function to parse file into monkey limbPosition
function readMonkeys(allLines)
    monkeyList = Array{Monkey,1}()
    items = Array{Any,1}()
    operator = ' '
    operationValuePre = ""
    operationValuePost = ""
    testValue = 0
    nextMonkeyTrue = 0
    nextMonkeyFalse = 0

    for line in allLines
        if (line=="")
            newMonkey = Monkey(items,operator,operationValuePre,operationValuePost,testValue,nextMonkeyTrue,nextMonkeyFalse,0)
            append!(monkeyList,[newMonkey])
            items = Array{Any,1}()
            operator = ' '
            operationValuePre = ""
            operationValuePost = ""
            testValue = 0
            nextMonkeyTrue = 0
            nextMonkeyFalse = 0
        else
            # get starting items
            if (!isnothing(match(r"Starting",line)))
                itemList = collect(eachmatch(r"[0-9]+",line))
                append!(items,[x for x in map(x->parse(Int,x.match),itemList)])
            # get operation to perform
            elseif (!isnothing(match(r"Operation",line)))
                foundOperatorData = collect(eachmatch(r"[\*\+]|old|[0-9]+",line))
                operationValuePre = foundOperatorData[1].match
                operator = foundOperatorData[2].match[1]
                operationValuePost = foundOperatorData[3].match
            elseif (!isnothing(match(r"Test",line)))
                testValue = parse(Int,match(r"[0-9]+",line).match)
                # print(string("\n",testValue))
            elseif (!isnothing(match(r"true",line)))
                nextMonkeyTrue = parse(Int,match(r"[0-9]+",line).match)
            elseif (!isnothing(match(r"false",line)))
                nextMonkeyFalse = parse(Int,match(r"[0-9]+",line).match)
            end
        end
    end
    
    return monkeyList
end

# Function to calculate greatest common divisor for all monkeys
function calculateGCD(monkeyList::Array{Monkey,1})
    gcd = 1

    for monkey in monkeyList
        gcd *= monkey.testValue
    end

    return gcd
end

# Part 1: chase monkeys for 20 rounds
function chaseMonkeys(monkeyList::Array{Monkey,1},verbose=false)
    for round = 1:20
        monkeyCounter = 0
        for monkey in monkeyList
            monkeyCounter += 1
            if (verbose)
                print(string("\nMonkey ",monkeyCounter))
                print(string("\n",monkey))
            end
            for i in lastindex(monkey.items):-1:1
                item = monkey.items[i]
                if (verbose)
                    print(string("\n  Inspecting item: ",item))
                end
                # define first operand
                firstOperand = nothing
                if (monkey.operationValuePre=="old")
                    firstOperand = item
                else
                    firstOperand = parse(Int,monkey.operationValuePre)
                end
                # define second operand
                secondOperand = nothing
                if (monkey.operationValuePost=="old")
                    secondOperand = item
                else
                    secondOperand = parse(Int,monkey.operationValuePost)
                end
                # perform operation
                if (monkey.operator=='*')
                    item = firstOperand*secondOperand
                elseif (monkey.operator=='+')
                    item = firstOperand+secondOperand
                end
                if (verbose)
                    print(string("\n  Worry level increased: ",item))
                end
                # divide worry level
                item = floor(item/3)
                if (verbose)
                    print(string("  Worry level decreased: ",item))
                end
                # run test on item
                divisionResult = item%monkey.testValue
                if (verbose)
                    print(string("\n  Remainder of division: ",divisionResult))
                end
                if (divisionResult==0)
                    append!(monkeyList[monkey.nextMonkeyTrue+1].items,[item])
                    splice!(monkey.items,i)
                    if (verbose)
                        print(string("  Item thrown to monkey: ",monkey.nextMonkeyTrue))
                    end
                else
                    append!(monkeyList[monkey.nextMonkeyFalse+1].items,[item])
                    splice!(monkey.items,i)
                    if (verbose)
                        print(string("  Item thrown to monkey: ",monkey.nextMonkeyFalse))
                    end
                end

                monkey.totalInspections +=1
            end
        end
    end

    return monkeyList
end

# Part 2: chase monkeys for 10000 rounds without reducing worry
function chaseMonkeysForever(monkeyList,verbose=false)
    gcd = calculateGCD(monkeyList)
    for round = 1:10000
        monkeyCounter = 0
        for monkey in monkeyList
            monkeyCounter += 1
            for i in lastindex(monkey.items):-1:1
                item = monkey.items[i]
                # define first operand
                firstOperand = nothing
                if (monkey.operationValuePre=="old")
                    firstOperand = item
                else
                    firstOperand = parse(Int,monkey.operationValuePre)
                end
                # define second operand
                secondOperand = nothing
                if (monkey.operationValuePost=="old")
                    secondOperand = item
                else
                    secondOperand = parse(Int,monkey.operationValuePost)
                end
                # perform operation
                if (monkey.operator=='*')
                    item = firstOperand*secondOperand
                elseif (monkey.operator=='+')
                    item = firstOperand+secondOperand
                end
                # fix value so it's not too high
                item = item%gcd
                # run test on item
                divisionResult = item%monkey.testValue
                if (divisionResult==0)
                    append!(monkeyList[monkey.nextMonkeyTrue+1].items,[item])
                    splice!(monkey.items,i)
                else
                    append!(monkeyList[monkey.nextMonkeyFalse+1].items,[item])
                    splice!(monkey.items,i)
                end

                monkey.totalInspections +=1
            end
        end

        if (verbose&&((round==1)||(round==20)||((round%1000)==0)))
            print(string("\nTotal inspections for round ",round,": ",[monkey.totalInspections for monkey in monkeyList]))
        end
    end

    return monkeyList
end

# Calculate everything in one run
function calculateEverything(filename,answer1=nothing,answer2=nothing)
    monkeyList = nothing

    open(filename) do file
        fileData = readlines(file)
        monkeyList = readMonkeys(fileData)
        monkeyList = chaseMonkeys(monkeyList,false)
    end

    maxMonkeyInteractions = sort([monkey.totalInspections for monkey in monkeyList])
    monkeyBusiness = maxMonkeyInteractions[end]*maxMonkeyInteractions[end-1]
    print(string("\nTotal monkey business moves: ",monkeyBusiness))
    # validate answer 1
    if (!isnothing(answer1))
        @assert(monkeyBusiness==answer1)
        print("\nFirst test passed!")
    end

    open(filename) do file
        fileData = readlines(file)
        monkeyList = readMonkeys(fileData)
        monkeyList = chaseMonkeysForever(monkeyList,false)
    end

    maxMonkeyInteractions = sort([monkey.totalInspections for monkey in monkeyList])
    monkeyBusiness = maxMonkeyInteractions[end]*maxMonkeyInteractions[end-1]
    print(string("\nTotal monkey business moves: ",monkeyBusiness))
    # validate answer 2
    if (!isnothing(answer2))
        @assert(monkeyBusiness==answer2)
        print("\nSecond test passed!")
    end
end

calculateEverything("Day11/Day11Test.txt",10605,2713310158)
calculateEverything("Day11/Day11Input.txt")