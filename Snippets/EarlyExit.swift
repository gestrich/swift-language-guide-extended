// snippet.hide
// Examples for the "Early exit" article.
// snippet.show

// snippet.guardBasic
func describe(_ rawTemperature: String?) -> String {
    guard let rawTemperature else {
        return "No reading"
    }
    guard let degrees = Int(rawTemperature) else {
        return "Unreadable reading: \(rawTemperature)"
    }
    return "\(degrees) degrees"
}

print(describe("90"))     // 90 degrees
print(describe("warm"))   // Unreadable reading: warm
print(describe(nil))      // No reading
// snippet.end

// snippet.nestedIfLet
func describeNested(_ rawTemperature: String?) -> String {
    if let rawTemperature {
        if let degrees = Int(rawTemperature) {
            return "\(degrees) degrees"
        } else {
            return "Unreadable reading: \(rawTemperature)"
        }
    } else {
        return "No reading"
    }
}
// snippet.end

// snippet.guardInLoop
func report(_ readings: [String]) {
    for reading in readings {
        guard let degrees = Int(reading) else {
            continue
        }
        print("\(degrees) degrees")
    }
}

report(["90", "warm", "32"])   // 90 degrees, 32 degrees
// snippet.end

// snippet.preconditionFailure
func requireDegrees(_ rawTemperature: String?) -> Int {
    guard let rawTemperature, let degrees = Int(rawTemperature) else {
        preconditionFailure("Caller must supply a numeric reading")
    }
    return degrees
}
// snippet.end
