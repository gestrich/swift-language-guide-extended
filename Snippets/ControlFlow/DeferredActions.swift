// snippet.hide
// Examples for the "Deferred actions" article.

func openConnection(_ name: String) -> String {
    print("opened \(name)")
    return name
}

func close(_ connection: String) {
    print("closed \(connection)")
}
// snippet.show

// snippet.withoutDefer
func sendWithoutDefer(to name: String, isValid: Bool) {
    let connection = openConnection(name)

    guard isValid else {
        close(connection)     // easy to forget on a new exit path
        return
    }

    print("sent over \(connection)")
    close(connection)
}
// snippet.end

// snippet.withDefer
func send(to name: String, isValid: Bool) {
    let connection = openConnection(name)
    defer {
        close(connection)
    }

    guard isValid else {
        return
    }

    print("sent over \(connection)")
}
// snippet.end

// snippet.readsAtExecution
var score = 1

if score < 10 {
    defer {
        print(score)   // 6
    }
    score += 5
}
// snippet.end

// snippet.mustBeReached
func process(_ items: [String]) {
    for item in items {
        if item.isEmpty {
            continue
        }
        defer {
            print("closed \(item)")
        }
        print("opened \(item)")
    }
}

process(["a", "", "b"])
// opened a, closed a, opened b, closed b
// snippet.end

// snippet.reverseOrder
func openTwo() {
    defer {
        print("released first")
    }
    defer {
        print("released second")
    }
    print("body")
}

openTwo()
// body, released second, released first
// snippet.end

// snippet.runsOnThrow
enum SendError: Error {
    case refused
}

func sendOrFail(to name: String) throws {
    let connection = openConnection(name)
    defer {
        close(connection)
    }
    throw SendError.refused
}
// snippet.end
