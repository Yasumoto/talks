slidenumbers: true

# Swift Package Manager

### **@jmsmith**, Site Reliability Engineer @**SlackHQ**

### 🐦 @Yasumoto

---

# Agenda

1. 📦 Creating a Package
	* Example with `vapor/http`
    * Concepts
2. 🆕 New in Swift 4.2
3. 💻 Contributing!
    * Starter Bugs 
    * Evolution Proposals

---

### 📦 Creating a Package

---

# 📦 Creating a Package

* The Swift Package Manager makes it simple to organize your code into reusable modules
* You can point to git repositories of Swift code to pull that into your project

---

# Example

```bash
~ $ mkdir ./curl
~ $ cd ./curl
~/curl $ ls
~/curl $
```

---

# Example

```bash
~/curl $ swift package init --type executable
Creating executable package: curl
Creating Package.swift
Creating README.md
Creating .gitignore
Creating Sources/
Creating Sources/curl/main.swift
Creating Tests/
Creating Tests/LinuxMain.swift
Creating Tests/curlTests/
Creating Tests/curlTests/curlTests.swift
Creating Tests/curlTests/XCTestManifests.swift
~/curl $
```

---

# Example

* `Package.swift`
* `Sources/curl/main.swift`

---

```swift
// swift-tools-version:4.2

import PackageDescription

let package = Package(
    name: "curl",
    dependencies: [
    ],
    targets: [
        .target(
            name: "curl",
            dependencies: []),
        .testTarget(
            name: "curlTests",
            dependencies: ["curl"]),
    ]
)
```

---

```swift
print("Hello world!")
```

---

```bash
~/curl $ swift build
Compile Swift Module 'curl' (1 sources)
Linking ./.build/x86_64-apple-macosx10.10/debug/curl
~/curl $
```

---

```bash
~/curl $ swift build
Compile Swift Module 'curl' (1 sources)
Linking ./.build/x86_64-apple-macosx10.10/debug/curl
~/curl $ ./.build/x86_64-apple-macosx10.10/debug/curl
Hello world!
~/curl $
```

---

# 🧠 Concepts

---

![inline](file:///Users/jmsmith/workspace/Baseline/Yasumoto/talks/2018/08/28/PackageConcepts_1.png)


---

* A *Package* is the core unit that you will build or operate upon.

* This consists of a collection of *.swift* source files, as well as a *Package Manifest*.

---

```swift
Package(
    name: String,
    pkgConfig: String? = nil,
    providers: [SystemPackageProvider]? = nil,
    products: [Product] = [],
    dependencies: [Dependency] = [],
    targets: [Target] = [],
    swiftLanguageVersions: [SwiftVersion]? = nil
)
```

---

![inline](file:///Users/jmsmith/workspace/Baseline/Yasumoto/talks/2018/08/28/PackageConcepts_2.png)

---

* Code within a *package* can be broken up into *Targets*.

* Each *Target* specifies a directory where its source code resides.

---

```swift
target(
    name: String,
    dependencies: [PackageDescription.Target.Dependency] = default,
    path: String? = default,
    exclude: [String] = default,
    sources: [String]? = default,
    publicHeadersPath: String? = default
) -> PackageDescription.Target
```

---

![inline](file:///Users/jmsmith/workspace/Baseline/Yasumoto/talks/2018/08/28/PackageConcepts_3.png)

---

* A *package* can contain multiple *Targets*.

* These will contain a disjoint set of Source files from each other.

* Hopefully this will include your *testTarget*, which will depend on one of your other targets.

* You can also depend on native code on the system, a *systemLibrary*.

---

```swift
testTarget(
    name: String,
    dependencies: [PackageDescription.Target.Dependency] = default,
    path: String? = default,
    exclude: [String] = default,
    sources: [String]? = default
) -> PackageDescription.Target

systemLibrary(
    name: String,
    path: String? = default,
    pkgConfig: String? = default,
    providers: [PackageDescription.SystemPackageProvider]? = default
) -> PackageDescription.Target
```

---

![inline](file:///Users/jmsmith/workspace/Baseline/Yasumoto/talks/2018/08/28/PackageConcepts_4.png)

---

* You will group your targets into a final **Product**.
* This will be one of two types:
    * *Library*: code for other packages to consume
    * *Executable*: A tool run by end-users

---

```swift
library(
    name: String,
    type: PackageDescription.Product.Library.LibraryType? = default,
    targets: [String]
) -> PackageDescription.Product

executable(
    name: String,
    targets: [String]
) -> PackageDescription.Product
```

---

![inline](file:///Users/jmsmith/workspace/Baseline/Yasumoto/talks/2018/08/28/PackageConcepts_4.png)

This is (mostly) a Swift Package! 📦

---

# Dependencies 📦📦📦

* The Swift Package Manager encourages code sharing and reuse.

* Your *Package* needs to define what other packages it depends on.

* Your *Target* needs to specify what targets it depends on.


---

![inline](file:///Users/jmsmith/workspace/Baseline/Yasumoto/talks/2018/08/28/PackageConcepts_5.png)

---

![inline](file:///Users/jmsmith/workspace/Baseline/Yasumoto/talks/2018/08/28/PackageConcepts_6.png)

---

```swift
package(
    url: String,
    from version: PackageDescription.Version
) -> PackageDescription.Package.Dependency

package(
    url: String,
    _ requirement: PackageDescription.Package.Dependency.Requirement
) -> PackageDescription.Package.Dependency

package(
    url: String,
    _ range: Range<PackageDescription.Version>
) -> PackageDescription.Package.Dependency

func package(
    url: String,
    _ range: ClosedRange<PackageDescription.Version>
) -> PackageDescription.Package.Dependency

/// Add a dependency to a local package on the filesystem.
package(
    path: String
) -> PackageDescription.Package.Dependency
```

---

![inline](file:///Users/jmsmith/workspace/Baseline/Yasumoto/talks/2018/08/28/PackageConcepts_7.png)

---

```swift
/// A dependency on a target in the same package.
target(
    name: String
) -> PackageDescription.Target.Dependency

/// A dependency on a product from a package dependency.
product(
    name: String,
    package: String? = default
) -> PackageDescription.Target.Dependency

byName(
    name: String
) -> PackageDescription.Target.Dependency

Target(stringLiteral value: String)
```

---

# Example

```bash
~/curl $ swift package init --type executable
Creating executable package: curl
Creating Package.swift
Creating README.md
Creating .gitignore
Creating Sources/
Creating Sources/curl/main.swift
Creating Tests/
Creating Tests/LinuxMain.swift
Creating Tests/curlTests/
Creating Tests/curlTests/curlTests.swift
Creating Tests/curlTests/XCTestManifests.swift
~/curl $
```

---

```swift
// swift-tools-version:4.2

import PackageDescription

let package = Package(
    name: "curl",
    dependencies: [
        .package(url: "https://github.com/vapor/http", from: "3.1.1"),
    ],
    targets: [
        .target(
            name: "curl",
            dependencies: [])]) // Wait for it
```

---

```bash
~/curl $ swift package update
Fetching https://github.com/vapor/http
Fetching https://github.com/vapor/core.git
Fetching https://github.com/apple/swift-nio.git
Fetching https://github.com/apple/swift-nio-ssl.git
Fetching https://github.com/apple/swift-nio-zlib-support.git
Fetching https://github.com/apple/swift-nio-ssl-support.git
Completed resolution in 6.91s
Cloning https://github.com/apple/swift-nio-ssl-support.git
Resolving https://github.com/apple/swift-nio-ssl-support.git at 1.0.0
Cloning https://github.com/vapor/core.git
Resolving https://github.com/vapor/core.git at 3.4.1
Cloning https://github.com/apple/swift-nio-ssl.git
Resolving https://github.com/apple/swift-nio-ssl.git at 1.2.0
Cloning https://github.com/vapor/http
Resolving https://github.com/vapor/http at 3.1.1
Cloning https://github.com/apple/swift-nio.git
Resolving https://github.com/apple/swift-nio.git at 1.9.2
Cloning https://github.com/apple/swift-nio-zlib-support.git
Resolving https://github.com/apple/swift-nio-zlib-support.git at 1.0.0
```

---

* At this point, work with either Xcode or your favorite text editor.
* All of these commands will work on either Linux or Darwin.

---

```bash
~/curl $ swift package generate-xcodeproj
warning: dependency 'HTTP' is not used by any target
generated: ./curl.xcodeproj
```

---

# Example

```swift
// swift-tools-version:4.2

import PackageDescription

let package = Package(
    name: "curl",
    dependencies: [
        .package(url: "https://github.com/vapor/http", from: "3.1.1"),
    ],
    targets: [
        .target(
            name: "curl",
            dependencies: ["HTTP"])]) // 💥
```

---

```
~/curl $ swift package generate-xcodeproj
generated: ./curl.xcodeproj
```

---

```swift
import HTTP

struct CurlError: Error {}

struct SlackTest: Codable {
    let ok: Bool
}

let slack = "slack.com"
let test = "/api/api.test"
```

---

```swift
let worker = MultiThreadedEventLoopGroup(numberOfThreads: 1)

let request = HTTPRequest(
    method: .GET,
    url: test)
let client = try HTTPClient.connect(
    scheme: .https,
    hostname: slack,
    port: 443,
    on: worker).wait()
let response = try client.send(request).wait()
```

---

```swift
let decoder = JSONDecoder()
guard let data = response.body.data else {
    throw CurlError()
}
let test = try decoder.decode(SlackTest.self, from: data)
if test.ok {
    print("Slack is up! 🎉")
} else {
    print("Slack is down!!! 📟")
}
```

---

```bash
~/curl $ swift build
Compile CNIOSHA1 c_nio_sha1.c
Compile CNIOLinux shim.c
Compile CNIODarwin shim.c
Compile CNIOOpenSSL empty.c
Compile CNIOZlib empty.c
Compile CNIOHTTPParser c_nio_http_parser.c
Compile CNIOAtomics src/c-atomics.c
Compile Swift Module 'NIOPriorityQueue' (2 sources)
Compile Swift Module 'Debugging' (3 sources)
Compile Swift Module 'COperatingSystem' (1 sources)
Compile Swift Module 'NIOConcurrencyHelpers' (2 sources)
Compile Swift Module 'NIO' (52 sources)
Compile Swift Module 'NIOTLS' (3 sources)
Compile Swift Module 'NIOHTTP1' (8 sources)
Compile Swift Module 'Async' (15 sources)
Compile Swift Module 'NIOFoundationCompat' (1 sources)
Compile Swift Module 'Bits' (12 sources)
Compile Swift Module 'NIOOpenSSL' (13 sources)
Compile Swift Module 'Core' (25 sources)
Compile Swift Module 'HTTP' (25 sources)
Compile Swift Module 'curl' (1 sources)
Linking ./.build/x86_64-apple-macosx10.10/debug/curl
```

---

```bash
~/curl $ ./.build/x86_64-apple-macosx10.10/debug/curl
Slack is up! 🎉
```

---

# 🆕 New in Swift 4.2

---

# "Limited Terminal" Support [^1]

* Simple progress bars for terminals without escape sequence support!

* Helpful for folks who use things like `eshell` in emacs.

---

# Package Version Parsing[^2]

* Packages which mix versions of the form *vX.X.X* with *Y.Y.Y* will now be parsed and ordered numerically.

---

# Much better scheme generation

* One scheme containing all regular and test targets of the root package.
* One scheme per executable target containing the test targets whose dependencies intersect with the dependencies of the exectuable target.

---

# Automatic Xcode Project Regeneration[^3]

* The *generate-xcodeproj* command has a new *--watch* option.
* This will automatically regenerate the Xcode project if changes are detected.
* This uses the *watchman*[^4] tool to detect filesystem changes.

---

# Local Dependencies

* *SE-201[^5]*

* Packages can now specify a dependency as *package(path: String)* to point to a path on the local filesystem which hosts a package.
* This will enable interconnected projects to be edited in parallel.

---

# System Library Targets

* *SE-208[^6]*

* The Package manifest now accepts a new type of target, *systemLibrary*.
* This deprecates "system-module packages" which are now to be included in the packages that require system-installed dependencies.


---

# SwiftVersion Enum

* *SE-209[^7]*

* The *swiftLanguageVersions* property no longer takes its Swift language versions via a freeform Integer array.
* Instead it should be passed as a new *SwiftVersion* enum array.


---

# 💻 Contributing!

---


[^1]: https://github.com/apple/swift-package-manager/pull/1489

[^2]: https://bugs.swift.org/browse/SR-6978

[^3]: https://github.com/apple/swift-package-manager/pull/1604

[^4]: https://facebook.github.io/watchman/docs/install.html

[^5]: https://github.com/apple/swift-evolution/blob/master/proposals/0201-package-manager-local-dependencies.md

[^6]: https://github.com/apple/swift-evolution/blob/master/proposals/0208-package-manager-system-library-targets.md

[^7]: https://github.com/apple/swift-evolution/blob/master/proposals/0209-package-manager-swift-lang-version-update.md