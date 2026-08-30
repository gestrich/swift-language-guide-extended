// snippet.hide
// Examples for the "Conditional expressions" article.
import Foundation
// snippet.show

// snippet.ifExpression
var temperature = 90

let advice = if temperature <= 32 {
    "Very cold. Consider wearing a scarf."
} else if temperature >= 86 {
    "Really warm. Don't forget sunscreen."
} else {
    "Not that cold. Wear a t-shirt."
}
// snippet.end

// snippet.switchExpression
func naturalCount(of count: Int) -> String {
    switch count {
    case 0: "no"
    case 1..<5: "a few"
    case 5..<12: "several"
    case 12..<100: "dozens of"
    default: "many"
    }
}

print("There are \(naturalCount(of: 62)) moons.")
// snippet.end

// snippet.silentTypo
var typoAdvice = "unset"
var unrelatedAdvice = "unset"

if temperature > 85 {
    unrelatedAdvice = "Too hot"   // meant typoAdvice
} else {
    typoAdvice = "Not too hot"
}
print(typoAdvice)   // "unset"
// snippet.end

// snippet.escapeHatch
let heatIndex: String = {
    if temperature > 85 {
        let humidityAdjusted = temperature + 5
        return "Too hot: \(humidityAdjusted)"
    } else {
        let windChill = temperature - 3
        return "Not too hot: \(windChill)"
    }
}()
// snippet.end

// snippet.explicitType
let adjustment: Double = if temperature > 85 { 0 } else { 1.5 }

let freezeWarning: String? = if temperature <= 32 {
    "Watch for ice."
} else {
    nil
}
// snippet.end

// snippet.positions
func adviceWithReturn(for degrees: Int) -> String {
    return if degrees > 85 { "hot" } else { "not hot" }
}

func adviceWithoutReturn(for degrees: Int) -> String {
    if degrees > 85 { "hot" } else { "not hot" }
}

let describe: (Int) -> String = { degrees in
    if degrees > 85 { "hot" } else { "not hot" }
}

struct WeatherReport {
    let degrees: Int

    var summary: String {
        if degrees > 85 { "wear sunscreen" } else { "wear a t-shirt" }
    }
}
// snippet.end

// snippet.throwingBranch
enum ReadingError: Error {
    case tooCold
    case tooHot
}

func rangeCheck(_ degrees: Int) throws -> String {
    if degrees > -100 {
        "In range"
    } else {
        let shortfall = -100 - degrees
        print("Out of range by \(shortfall) degrees")
        throw ReadingError.tooCold
    }
}

func reject(_ degrees: Int) throws {
    throw if degrees < -100 {
        ReadingError.tooCold
    } else {
        ReadingError.tooHot
    }
}
// snippet.end

// snippet.neverBranch
let reading = if temperature > -460 {
    "Valid reading"
} else {
    fatalError("Below absolute zero")
}
// snippet.end

// snippet.switchFallthrough
enum Season {
    case spring, summer, fall, winter
}

let season = Season.summer

let gear = switch season {
case .spring:
    fallthrough
case .summer:
    "Light layers"
case .fall, .winter:
    "Heavy layers"
}
print(gear)   // "Light layers"
// snippet.end

// snippet.ternary
let ternaryAdvice = temperature > 85 ? "Too hot" : "Not too hot"

let nestedTernary = temperature > 95 ? "Way too hot"
    : temperature > 85 ? "Too hot" : "Not too hot"

let chainedExpression = if temperature > 95 {
    "Way too hot"
} else if temperature > 85 {
    "Too hot"
} else {
    "Not too hot"
}
// snippet.end

// snippet.nested
func comfort(at degrees: Int, humid: Bool) -> String {
    if degrees <= 32 {
        if humid { "Cold and damp." } else { "Cold." }
    } else {
        humid ? "Warm and sticky." : "Warm."
    }
}
// snippet.end
