// snippet.hide
// Examples for the "Patterns" article.
// snippet.show

// snippet.rangePattern
for count in [0, 3, 62] {
    switch count {
    case 0:
        print("no moons")
    case 1..<5:
        print("a few moons")
    default:
        print("many moons")
    }
}
// snippet.end

// snippet.tildeEqual
let approximateCount = 62

if 12..<100 ~= approximateCount {
    print("dozens")
}
// snippet.end

// snippet.customType
struct Version: Equatable, Comparable {
    let build: Int

    static func < (lhs: Version, rhs: Version) -> Bool {
        lhs.build < rhs.build
    }
}

for version in [Version(build: -1), Version(build: 0), Version(build: 7)] {
    switch version {
    case Version(build: Int.min)..<Version(build: 0):
        print("before the first build")
    case Version(build: 0):
        print("the first build")
    default:
        print("a later build")
    }
}
// snippet.end

// snippet.valueBinding
for point in [(3, 0), (2, 5)] {
    switch point {
    case let (x, 0):
        print("on the x-axis at \(x)")
    case let (x, y):
        print("at \(x), \(y)")
    }
}
// snippet.end

// snippet.bindingForms
for point in [(3, 0)] {
    switch point {
    case (let x, let y):
        print("at \(x), \(y)")
    }
}
// snippet.end

// snippet.whereClause
for point in [(2, -2), (4, 4), (1, 9)] {
    switch point {
    case let (x, y) where x == -y:
        print("on the line x == -y")
    case let (x, y) where x == y:
        print("on the line x == y")
    case let (x, _):
        print("elsewhere, with x of \(x)")
    }
}
// snippet.end

// snippet.compoundCase
for point in [(9, 0), (0, 4), (3, 3)] {
    switch point {
    case (let distance, 0), (0, let distance):
        print("on an axis, \(distance) from the origin")
    default:
        print("not on an axis")
    }
}
// snippet.end

// snippet.compoundWhere
for point in [(9, 0), (2, 0), (0, 4)] {
    switch point {
    case (let distance, 0) where distance > 5, (0, let distance):
        print("far out on x, or anywhere on y: \(distance)")
    default:
        print("neither")
    }
}
// snippet.end

// snippet.optionalPattern
let names: [String?] = ["Bill", nil, "Tony"]

for case let name? in names {
    print(name)   // Bill, Tony
}
// snippet.end

// snippet.typeCastPattern
let values: [Any] = [1, "two", 3.0]

for value in values {
    switch value {
    case is Int:
        print("an Int")
    case let text as String:
        print("a String of \(text.count) characters")
    default:
        print("something else")
    }
}
// snippet.end

// snippet.ifCase
let origin = (0, 0)

if case (0, 0) = origin {
    print("at the origin")
}

if case 12..<100 = approximateCount {
    print("dozens")
}
// snippet.end

// snippet.forCase
let readings = [(1, 0), (2, 2), (3, 0)]

for case let (x, 0) in readings {
    print("on the x-axis at \(x)")   // 1, 3
}

for case let (x, y) in readings where x == y {
    print("on the line x == y at \(x), \(y)")   // 2, 2
}
// snippet.end

// snippet.forWhere
for value in 0...10 where value != 5 {
    print(value)
}
// snippet.end
