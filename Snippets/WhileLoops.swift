// snippet.hide
// Examples for the "While loops" article.
// snippet.show

// snippet.whileLoop
var attempt = 1
while attempt < 15 {
    attempt += 1
}
print(attempt)   // 15
// snippet.end

// snippet.repeatWhile
var countdown = 0
repeat {
    countdown -= 1
} while countdown > 0
print(countdown)   // -1
// snippet.end

// snippet.advanceFirst
let names = ["Ann", "Bo", "Cy"]

var advanceFirstIndex = 0
while advanceFirstIndex < names.count {
    advanceFirstIndex += 1
    if advanceFirstIndex < names.count {
        print(names[advanceFirstIndex])
    }
}
// snippet.end

// snippet.processFirst
var processFirstIndex = 0
while processFirstIndex < names.count {
    print(names[processFirstIndex])
    processFirstIndex += 1
}
// snippet.end

// snippet.repeatProcessFirst
var repeatIndex = 0
repeat {
    print(names[repeatIndex])
    repeatIndex += 1
} while repeatIndex < names.count
// snippet.end
