// snippet.hide
// Examples for the "Switch statements" article.
// snippet.show

// snippet.basic
let letter: Character = "a"

switch letter {
case "a":
    print("the first letter")
case "z":
    print("the last letter")
default:
    print("some other letter")
}
// snippet.end

// snippet.emptyCase
for hour in [-1, 6, 12, 18] {
    switch hour {
    case ..<0:
        break        // not a real hour; nothing to report
    case 6:
        print("Half the day is gone")
    case 12:
        print("The day is over")
    default:
        print("Somewhere in between")
    }
}
// snippet.end

// snippet.rangeNeedsDefault
let reading = 5

switch reading {
case Int.min...Int.max:
    print("Every Int lands here")
default:
    print("Unreachable, and still required")
}
// snippet.end

// snippet.firstMatchWins
for point in [(0, 0), (3, 0), (2, 5)] {
    switch point {
    case (0, 0):
        print("at the origin")
    case (_, 0):
        print("on the x-axis")
    default:
        print("elsewhere")
    }
}
// at the origin, on the x-axis, elsewhere
// snippet.end

// snippet.fallthrough
let grade: Character = "a"

switch grade {
case "a":
    print("top mark")
    fallthrough
case "b" where grade == "b":
    print("passing")
default:
    print("other")
}
// prints "top mark" then "passing"
// snippet.end

// snippet.breakInSwitch
for value in 0...2 {
    switch value {
    case 0:
        break        // ends the switch, not the loop
    default:
        print("value is \(value)")
    }
    print("still inside the loop")
}
// snippet.end
