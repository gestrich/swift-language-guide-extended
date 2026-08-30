// snippet.hide
// Examples for the "If statements" article.
// snippet.show

// snippet.basic
let temperatureInFahrenheit = 90

if temperatureInFahrenheit <= 32 {
    print("Very cold. Consider wearing a scarf.")
} else if temperatureInFahrenheit >= 86 {
    print("Really warm. Don't forget sunscreen.")
} else {
    print("Not that cold. Wear a t-shirt.")
}
// snippet.end

// snippet.noElse
if temperatureInFahrenheit >= 86 {
    print("Really warm.")
} else if temperatureInFahrenheit <= 32 {
    print("Very cold.")
}
// snippet.end

// snippet.testExplicitly
let itemCount = 3
if itemCount != 0 {
    print("Has items.")
}

let shopper: String? = "Bill"
if shopper != nil {
    print("Has a shopper.")
}
// snippet.end

// snippet.assignFromBranches
let advice: String
if temperatureInFahrenheit >= 86 {
    advice = "Wear sunscreen."
} else {
    advice = "Wear a t-shirt."
}
print(advice)
// snippet.end
