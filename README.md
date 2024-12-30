### Steps to Run the App

1. Clone the project

        git clone https://github.com/willbur1984/async-recipes-example.git

1. `cd` into the cloned directory

        cd async-recipes-example

1. Open the *async-recipes.xcodeproj* file

        open async-recipes.xcodeproj

1. Run the app using *Product -> Run*

### Focus Areas: What specific areas of the project did you prioritize? Why did you choose to focus on these areas?

The priorities were:

1. Ensuring the interface of the `ImageManager` class met the requirements and was thread safe
1. Adding only the necessary convenience extensions to speed up boilerplate (e.g. `ScopeFunctions` from [Feige](https://github.com/Kosoku/Feige), I am the author)
1. Adding source comments for public facing API
1. Adding unit tests to cover what is reasonable (e.g. decoding, image caching)

I felt this was the best priority order given the assignment requirements.

### Time Spent: Approximately how long did you spend working on this project? How did you allocate your time?

I spent approximately 8 hours over the course of 3 days. The bulk of the time was spent in the following areas:

1. Design and implementation of the `ImageManager` class
1. Design and implementation of the `Recipe` model and the `RecipeCell` table view cell
1. Adding source comments for public API
1. Adding unit tests

### Trade-offs and Decisions: Did you make any significant trade-offs in your approach?

There are always more features that could be added to the `ImageManager` class, it would just require additional time. Realistically, I would wrap a third party library to implement the required functionality (e.g. [KingFisher](https://github.com/onevcat/Kingfisher)).

### Weakest Part of the Project: What do you think is the weakest part of your project?

I am satisfied with the unit tests covering the core functionality (decoding, image caching). Ideally, I would add comprehensive integration (i.e. UI) tests to cover interactions in the app.

### Additional Information: Is there anything else we should know? Feel free to share any insights or constraints you encountered.

Determining a reasonable way to unit test `async` functions was interesting and I ultimately ended up using `XCTestExpectation`:

```swift
let expectation = XCTestExpectation()
var result: Type

Task {
    result = ...
    expectation.fulfill()
}

wait(for: [expectation])
// XCTAssert variants
```

There is probably a cleaner way to handle this with mocking or a `XCTestCase` subclass to abstract the boilerplate away.