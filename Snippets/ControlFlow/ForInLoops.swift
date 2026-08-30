// snippet.hide
// Examples for the "For-in loops" article.
// snippet.show

// snippet.basic
for name in ["Bill", "Tony"] {
    print(name)
}
// snippet.end

// snippet.varBinding
for var index in 1...3 {
    if index == 1 {
        index = 100
    }
    print(index)   // 100, 2, 3
}
// snippet.end

// snippet.numericRange
for multiplier in 1...5 {
    print("\(multiplier) times 5 is \(multiplier * 5)")
}

for tickMark in 0..<3 {
    print(tickMark)   // 0, 1, 2
}
// snippet.end

// snippet.ignoreElement
var power = 1
for _ in 1...8 {
    power *= 2
}
print(power)   // 256
// snippet.end

// snippet.strideTo
for minuteMark in stride(from: 0, to: 60, by: 15) {
    print(minuteMark)   // 0, 15, 30, 45
}
// snippet.end

// snippet.strideThrough
for hourMark in stride(from: 3, through: 12, by: 3) {
    print(hourMark)   // 3, 6, 9, 12
}

for missedEnd in stride(from: 0, through: 5, by: 2) {
    print(missedEnd)   // 0, 2, 4
}
// snippet.end

// snippet.dictionary
let numberOfLegs = ["spider": 8, "ant": 6, "cat": 4]
for (animalName, legCount) in numberOfLegs {
    print("\(animalName)s have \(legCount) legs")
}
// snippet.end

// snippet.dictionaryTuple
for entry in numberOfLegs {
    print("\(entry.key): \(entry.value)")
}
// snippet.end

// snippet.enumerated
for (offset, name) in ["Bill", "Tony"].enumerated() {
    print("\(offset): \(name)")   // 0: Bill, 1: Tony
}
// snippet.end

// snippet.whereClause
for tickMark in 0...10 where tickMark != 5 {
    print(tickMark)
}
// snippet.end
