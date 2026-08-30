// snippet.hide
// Examples for the "Control transfer statements" article.
// snippet.show

// snippet.continueBasic
for value in 0...10 {
    if value == 5 {
        continue
    }
    print(value)
}
// snippet.end

// snippet.continueVsWhere
for value in 0...10 where value != 5 {
    print(value)
}
// snippet.end

// snippet.breakInnerLoop
for row in 0..<3 {
    for column in 0..<3 {
        if column == 1 {
            break        // leaves the column loop only
        }
        print("\(row), \(column)")
    }
    print("finished row \(row)")
}
// snippet.end

// snippet.labeledLoops
outerLoop: for row in 0..<3 {
    for column in 0..<3 {
        if column == 1 {
            continue outerLoop
        }
        if row == 2 {
            break outerLoop
        }
        print("\(row), \(column)")
    }
}
// snippet.end

// snippet.repeatLabel
var attempt = 0
retry: repeat {
    attempt += 1
    if attempt == 2 {
        continue retry
    }
    print("attempt \(attempt)")
} while attempt < 4
// snippet.end

// snippet.breakLoopFromSwitch
search: for value in 0...5 {
    switch value {
    case 3:
        print("found 3")
        break search
    default:
        print("checking \(value)")
    }
}
// snippet.end

// snippet.flag
let grid = [[1, 2], [3, 4]]
let target = 3

var found = false
for row in grid {
    for cell in row {
        if cell == target {
            found = true
            break
        }
    }
    if found {
        break        // easy to leave out
    }
}
// snippet.end

// snippet.labelInsteadOfFlag
scan: for row in grid {
    for cell in row {
        if cell == target {
            print("found \(cell)")
            break scan
        }
    }
}
// snippet.end

// snippet.labeledIf
for value in 0..<3 {
    evenWork: if value.isMultiple(of: 2) {
        print("setup \(value)")
        if value == 2 {
            break evenWork
        }
        print("finish \(value)")
    }
    print("end of pass \(value)")
}
// snippet.end
