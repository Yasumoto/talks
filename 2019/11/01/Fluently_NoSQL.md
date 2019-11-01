build-lists: true

# Fluently NoSQL

[.footer: Server Side Swift 2019, Copenhagen]

^ Hello! What an exciting conference, I cannot believe it's almost over!

^ I'm so excited to share with you the journey to getting an internal application deployed, and the components required to get there.

^ In particular, we'll talk about integrating Vapor's Fluent ORM with AWS' DynamoDB.

![50%]

---- 

[.build-lists: false]

# Joe Smith

### Site Reliability Engineer at Slack

###  @Yasumoto

* Performance 🏎
* Efficiency 💸
* Reliability 💪
* Scalability 📈

![100% right]

^ Lots of time spent with dynamic languages

^ Also a ton of time oncall, and as I'm bouncing between meetings or commutes, rarely have a comfortable way to use my laptop.

^ Would *love* to be able to use my phone for more incident response!

---- 

## Agenda

* 🔴 Patient Road to Production
* 📦 DynamoDB
* 🌴 `AWSSDKSwift`
* 💧 Fluent DynamoDB

![100% right]

^ I hear so many folks ask how to get started with some Swift in their infrastructure. I'll share a little bit of my perspective to start us off.

^ Then we'll start at the bottom of an application's stack, it's datastore.

^ We'll slowly move up the stack, talking about an Amazon Web Services client library, then integrate it with Fluent.

---- 

# Launching to Prod

![]

[.footer: Photo by SpaceX on Unsplash]

^ To build something that your customers rely upon, you need to have utmost confidence in its success.

^ That's not just something that can happen over a few months.

^ Need to maintain investment, understanding, and consider what work needs to be done now to enable you in the future.

---- 

## Ecosystem

![photo-1543133690-e427d2bdd1dd]

^ Swift on the server is *very* new 

^ I love the way the community is working together to build out the necessary frameworks for us to be successful.

^ Starting with shared, reusable components allows us to build on top of those, solving more specific problems each time.

[.footer: Photo by Markus Spiske on Unsplash]

---- 

## Introducing New Technology

![photo-1530319067432-f2a729c03db5]

^ Slack's core Web API is a monolithic application written in Hacklang on HHVM

^ Also have services in Java & Go for the real-time messaging stack

^ Tools written in Python, Shell, golang, and Swift

^ Need to be thoughtful of how & when to introduce a new stack

[.footer: Photo by Tyler Lastovich on Unsplash]

---- 

## Roadmap

![]

[.footer: Photo by Ryan Stone on Unsplash]

^ Start with small, well-scoped tools. For me, that meant building command-line tools used for things like SSL Certificate management.

^ I also used to work directly on top of AWS, so it was important to have a reliable AWS client.

^ So worth your time to Invest in libraries, these will pay off.

^ As you amass these components, you'll find opportunity to combine technology interests with business use cases

----


## 🛑 Emergency Stop

1. What Loadtests are running right now?
2. How do I stop all loadtests NOW?

^ For me, that opportunity looked like a small service to assist with some major loadtest efforts we were performing.

^ As a Site Reliability Engineer, we have many tools in our tool belt.

^ Loadtesting and simulating large-scale events are powerful, but can be dangerous!

^ We wanted to be able to answer two questions quickly, so we built `Emergency Stop`.


---- 

(img)

^ We created a service, and integrated our 3 or 4 loadtesting tools to register themselves with Emergency Stop.

^ This allowed engineers and incident responders to track what experiments were in-flight

^ We also wanted a "big red button" to stop anything running immediately.

^ These tools would also query Emergency Stop to look for whether it was safe to proceed.

---- 

### Data Structure — `ServiceLock`

1. **ServiceName** 🌍  always  `global`
2. **Version** 📜 A historical log
3. **IsIncidentOngoing** 🔴 the "red button"
4. **Username** 🙋‍♀️ Who flipped the switch?
5. **Timestamp** ⌚️ When?
6. **Message**  ➡️ Where's the incident channel?

^ We'll use the "big red button" itself as our example throughout this talk.

----


## End Goal

![]

^ We identified a problem we needed to solve, which while helpful, was not mission critical.

^ This is our first service written in Swift, leveraging the language, standard library, and the APIs of Fluent & Vapor.

^ Also an opportunity to battle-test the AWSSDKSwift

^ It's running on our internal kubernetes cluster via EKS.

[.footer: Photo by Benjamin Davies on Unsplash]

---- 

## Low-risk Production Experience

![photo-1455747634646-0ef67dfca23f]

[.footer: Photo by Dawn Armfield on Unsplash]

^ This is in contrast to putting new technology *directly* in the hot path of user traffic.

^ Sometimes it works, but as your friendly neighborhood SRE, I **strongly** urge against it!

---- 

## 🤔 Picking a Datastore (at Slack)

* MySQL
* Something Else

^ MySQL is the "supported" solution by our Database Reliability Engineering team, but requires maintenance, ongoing support, and an oncall rotation.

^ We wanted something as low-overhead as possible, able to be controlled by APIs and configuration, not chef and kernel reboots.

^ After considering the options, I settled on...

----


# DynamoDB

![]

[.footer: Photo by Ian Battaglia on Unsplash]

^ Announced by Amazon CTO Werner Vogels in 2012

^ Key-Value Storage

^ Denormalized Data

---- 

> Most of our services... store and retrieve data by primary key and do not require the **complex querying** and management functionality offered by an RDBMS. 

-- Dynamo Paper


^ Reading the Dynamo paper gives some insights into its usage. 

^ The infrastructure engineers realized that for their usecase, most teams were *not* taking advantage of the features offered by a SQL datastore.

^ If folks could give up some flexibility and take on some constraints, that opened up some interesting options!

---- 

## Key Concepts

[.build-lists: false]

1. Tables
2. Items & Attributes
3. Primary Keys

^ These are the "nouns" of DynamoDB.

---- 

### Table

1. Name
2. Hash Key
3. Range Key
4. Capacity

^ A table is just a collection of data records.

^ Very similar to a table in MySQL
 ^ It has a few properties, the Hash Key & optional Range Key compose the _primary key_

[.build-lists: false]

----

### Items

![]

[.footer: Photo by Karen Vardazaryan on Unsplash]

^ Single data record, or "row" in a table

^ Each item is uniquely defined by a Primary Key

----

### Attributes (Values)

[.build-lists: false]

- Scalars
	- Single items
- Collections
	- Groups of values

^ Each Item is composed of a group of Attributes

^ You can specify a single value or several

---- 

### Scalar Values

* `Binary`
* `Boolean`
* `Number`
* `Null`
* `String`

[.build-lists: false]

^ These are individual values

---- 
### Collection Values

1. `Binary Set`
2. `List`
3. `Map`
4. `Number Set`
5. `String Set`

[.build-lists: false]

^ And these are ways to group attributes. Note that `List` and `Map` take any type of Attribute.

---- 

### Primary Key

1. Simple Primary Key — Hash Key
2. Composite Primary Key
	1. Hash Key
	2. Sort Key

^ Each item in a table is uniquely identified by a primary key.
 ^ There are two types.

^ A simple primary key made up of just a partition key. Similar to a "normal" KV store like Memcache.

^ A composite primary key made up of a partition key and a sort key. Enables complex queries.

---- 

## Scalars as Primary Keys

[.build-lists: false]

1. String
2. Numbers
3. Binary

^ These can all be used as primary keys

---- 


### Data Structure — `ServiceLock`

1. 🌍  `ServiceName` ( String ) — Hash Key
2. 📜  `Version` ( Int ) — Sort Key
3. 🔴  `IsIncidentOngoing` ( Bool )
4. 🙋‍♀️  `Username` ( String )
5. ⌚️  `Timestamp`( String )
6. ➡️  `Message` ( String )

^ Bringing this back to our "Red Button", these are the types we'll use for each field.

---- 

resource "aws_dynamodb_table" "emergency_stop_service_lock" {
  name           = "emergency-stop-service-lock"
  read_capacity  = 10
  write_capacity = 10
  hash_key       = "ServiceName"
  range_key      = "Version"

  attribute {
    name = "ServiceName"
    type = "S"
  }

  attribute {
    name = "Version"
    type = "N"
  }
}

^ We're using Terraform to create a "resource"— a DynamoDB Table.

^ It's named `emergency-stop-service-lock`

^ Note the `hash_key` and `range_key` (or `sort_key` make up our composite Primary Key)

^ We set read/write capacity instead of specifying an instance size or anything like that.

^ This is very low write volume, and thanks to caching in the application relatively low read volume as well.

----

| Service Name | Version | Is Incident Ongoing | User name | Time stamp | Message |
| --- | --- | --- | --- | --- | --- |
|  global  | 1 | true  | Jim | 8/25/2019, 2:04:31 AM | Error! |
|  global  | 2 | false   | Joe | 8/27/2019, 7:13:40 PM | Fixed  |

^ So as an example, we can see the first value (at `Version` **1**) shows there was a problem, so the Emergency Stop was pressed.

^ It must've been a doozy, since it was fixed 2 days later.

----

| Service Name | Version | Is Incident Ongoing | User name | Time stamp | Message |
| --- | --- | --- | --- | --- | --- |
|  global  | 1 | true  | Jim | 8/25/2019, 2:04:31 AM | Error! |
|  global  | 2 | false   | Joe | 8/27/2019, 7:13:40 PM | Fixed  |

^ When you're querying, you can **only** access this by the composite primary key.

^ I'm not going to talk about it this time, but if you wanted "all times Joe hit the button" you would create a `Secondary Index` to track that.

^ **Secondary Indexes** provide an additional "view" or "rotation" on the data to enable additional access patterns.

----

## Scalability

![]

[.footer: Photo by Maria Molinero on Unsplash]

^ Unlike most relational databases, DynamoDB can scale "horizontally" assuming you plan your data model correctly

^ Note that you need to pick your Primary Key well, that's what Dynamo uses to determine which nodes host your data.
 ^ Choosing poorly means you'll have "hot shards" that are overloaded by too many requests!

---- 

## [https://dynamodbguide.com]

### By Alex DeBrie

![]

^ To learn more, I **highly** recommend _ DynamoDB, explained._ by Alex DeBrie.

[.footer: Photo by Aron Visuals on Unsplash]

----

# AWS SDK Swift

* Created by Yuki (**@noppoMan**)
* Major contributions from **@jonnymacs** and **@adam-fowler**

![]

[.footer: Photo by Levi Morsy on Unsplash]

---- 

## Two Components

* `aws-sdk-swift-core`
* `aws-sdk-swift`

![]

[.footer: Photo by Genevieve Perron-Migneron on Unsplash]

^ The Core solves authentication, encoding/decoding, an HTTP client, and error propagation.

^ The second part is the "main" SDK, which contains a Code Generator and the actual APIs & request/response Shapes

---- 

## AWS SDK Swift Core

![]

[.footer: Photo by Paweł Czerwiński on Unsplash]

^ We're going to walk through some of the functionality this provides, inspired by other language implementations.

----
## `CredentialProvider`

/// Protocol defining requirements for object providing AWS credentials
public protocol CredentialProvider {
    var accessKeyId: String { get }
    var secretAccessKey: String { get }
    var sessionToken: String? { get }
    var expiration: Date? { get }
}

^ The first thing you'll need to do is have credentials with appropriate permissions to make your API calls!

^Three ways to plug in your credentials.

^ Environment Variables
INI File (`~/.aws`)
Metadata Service (IAM or ECS Profile), which is the best practice.

---- 

## AWS SDK Swift Core — Hashing

* 💻 `CommonCrypto`
or
* 🐧 `CAWSSDKOpenSSL`

1. `hmac` — hash-keyed message authentication code
2. `sha256`
3. `md5`

![]

[.footer: Photo by chris panas on Unsplash]

^ In order to properly sign and authenticate our requests, we need some cyptographic functionality.

^ We pick `CommonCrypto` if it's available on Darwin platforms, otherwise look for OpenSSL or LibreSSL.

^ We need an `hmac` function for nearly each part of the request signature, as well as `sha256` for the body and `md5`for S3.

---- 

## AWS SDK Swift Core — `HTTPCLient`

public final class HTTPClient {
    public struct Request {
        var head: HTTPRequestHead
        var body: Data = Data()
    }
    
    public struct Response {
        let head: HTTPResponseHead
        let body: Data
        public func contentType() -> String?
    }
    
    public enum HTTPError: Error {
        case malformedHead, malformedBody, malformedURL
    }

	public init(url: URL, eventGroup: EventLoopGroup)

	public func connect(_ request: Request) -> EventLoopFuture<Response>

	public func close(_ callback: @escaping (Error?) -> Void)
}

^ We have our own low-level HTTP client.

^ We've considered migrating to the `AsyncHTTPClient`, but it does not yet support `NIOTransportServices` which would limit the platforms we can support.

---- 

public class AWSClient {
    public enum RequestError: Error {
        case invalidURL(String)
    }

	public var endpoint: String

	public static let eventGroup: EventLoopGroup

    public func signURL(url: URL,
						httpMethod: String,
						expires: Int = 86400) -> URL
...

^ The HTTPClient is wrapped by an `AWSClient`, which is the workhorse of the SDK. 

---- 

public func send<Output: AWSShape, Input: AWSShape>(
	operation operationName: String,
	path: String,
	httpMethod: String,
	input: Input) -> Future<Output> {
        return signer.manageCredential().thenThrowing { _ in
            let awsRequest = try self.createAWSRequest(
                operation: operationName,
                path: path,
                httpMethod: httpMethod,
                input: input
            )
            return try self.createNioRequest(awsRequest)
        }.then { nioRequest in
            return self.invoke(nioRequest)
        }.thenThrowing { response in
            return try self.validate(operation: operationName, response: response)
        }
}

^ When we want to make an API request, we first asynchronously check that credentials are set or refreshed if necessary.

^ After that succeeds, we will use our input values to construct and sign the request with our credentials.

----

public func send<Output: AWSShape, Input: AWSShape>(
	operation operationName: String,
	path: String,
	httpMethod: String,
	input: Input) -> Future<Output> {
        return signer.manageCredential().thenThrowing { _ in
            let awsRequest = try self.createAWSRequest(
                operation: operationName,
                path: path,
                httpMethod: httpMethod,
                input: input
            )
            return try self.createNioRequest(awsRequest)
        }.then { nioRequest in
            return self.invoke(nioRequest)
        }.thenThrowing { response in
            return try self.validate(operation: operationName, response: response)
        }
}


^ The AWSClient knows how to encode and decode `awsRequest` / response headers and bodies based on the serviceProtocol.

^ We use NIO to send the request to aws, and return a future response object to the client.

---- 

public func send<Output: AWSShape, Input: AWSShape>(
	operation operationName: String,
	path: String,
	httpMethod: String,
	input: Input) -> Future<Output> {
        return signer.manageCredential().thenThrowing { _ in
            let awsRequest = try self.createAWSRequest(
                operation: operationName,
                path: path,
                httpMethod: httpMethod,
                input: input
            )
            return try self.createNioRequest(awsRequest)
        }.then { nioRequest in
            return self.invoke(nioRequest)
        }.thenThrowing { response in
            return try self.validate(operation: operationName, response: response)
        }
}

^ When the response is received, it is decoded, validated then mapped to the appropriate response type and the future is completed.

^ If it is not successful then `AWSClient` will throw an `AWSErrorType`.

---- 

## AWS SDK Swift Dynamo Client

1. `AttributeValue`
2. `getItem` / `putItem`
3. `query`

^ Now we'll dive into the code-generated DynamoDB client itself.

---- 

### `AttributeValue`
/// An attribute of type Binary. For example:
/// "B": "dGhpcyB0ZXh0IGlzIGJhc2U2NC1lbmNvZGVk"
public let b: Data?

/// An attribute of type Boolean. For example:  "BOOL": true
public let bool: Bool?

/// An attribute of type Number. For example:  "N": "123.45"
/// Numbers are sent across the network to DynamoDB as strings,
/// to maximize compatibility across languages and libraries.
/// However, DynamoDB treats them as number type attributes
/// for mathematical operations.
public let n: String?

/// An attribute of type Null. For example:  "NULL": true
public let null: Bool?

/// An attribute of type String. For example:  "S": "Hello"
public let s: String?

^ Here are the ways to represent the different `AttributeValue` types with this library.

^ Calling out that Number is _not_ `Numeric`, but instead passed to Dynamo as a `String` !

---- 
### `AttributeValue`
/// An attribute of type Binary Set. For example:
/// "BS": ["U3Vubnk=", "UmFpbnk=", "U25vd3k="]
public let bs: [Data]?

/// An attribute of type List. For example: 
/// "L": [ {"S": "Cookies"} , {"S": "Coffee"}, {"N", "3.14159"}]
public let l: [AttributeValue]?

/// An attribute of type Map. For example:
/// "M": {"Name": {"S": "Joe"}, "Age": {"N": "35"}}
public let m: [String: AttributeValue]?

/// An attribute of type Number Set. For example:
/// "NS": ["42.2", "-19", "7.5", "3.14"]
public let ns: [String]?

/// An attribute of type String Set. For example:
/// "SS": ["Giraffe", "Hippo" ,"Zebra"]
public let ss: [String]?

----

public class AttributeValue: AWSShape {
    public init(b: Data? = nil, bool: Bool? = nil,
			    bs: [Data]? = nil, l: [AttributeValue]? = nil,
				m: [String: AttributeValue]? = nil,
				n: String? = nil, ns: [String]? = nil,
				null: Bool? = nil, s: String? = nil,
				ss: [String]? = nil) {
        self.b = b
        self.bool = bool
        self.bs = bs
        self.l = l
        self.m = m
        self.n = n
        self.ns = ns
        self.null = null
        self.s = s
        self.ss = ss
    }         

^ This is a class which has a pretty big initializer, and trying to figure out what's set can be a challenge.

^ In `FluentDynamoDB`, we've created a `DynamoValue` which makes this much nicer.

---- 

## Fetching a Single Item


///  The GetItem operation returns a set of attributes
/// for the item with the given primary key.
public func getItem(_ input: GetItemInput) -> Future<GetItemOutput> {
    return client.send(operation: "GetItem",
					   path: "/",
         	           httpMethod: "POST",
                       input: input)
}

^ Calling `getItem` is very much like using a traditional key-value store; the `input` contains a `key` to correspond with the primary key you want to retrieve.

^  If there is no matching item, GetItem does not return any data and there will be no Item element in the response.  

---- 

### `GetItemInput`

/// Determines the read consistency model
public let consistentRead: Bool?

/// A map representing the primary key of the item to retrieve.
public let key: [String: AttributeValue]

/// The name of the table containing the requested item.
public let tableName: String

^ This is a truncated view of this `GetItemInput`

^ GetItem provides an eventually consistent read by default, so you may get stale data.

^ If your application requires a strongly consistent read, set ConsistentRead to true.
  
^ Although a strongly consistent read might take more time than an eventually consistent read, it always returns the last updated value.

---- 

## Setting Items

///  Creates a new item, or replaces an old item with a new item.
public func putItem(_ input: PutItemInput) -> Future<PutItemOutput> {
    return client.send(operation: "PutItem",
					   path: "/",
					   httpMethod: "POST",
					   input: input)
}

^ If an item that has the same primary key as the new item already exists in the specified table, the new item completely replaces the existing item. 

^ You can perform a conditional put operation (add a new item if one with the specified primary key doesn't exist), or replace an existing item if it has certain attribute values.

----

## Setting Items

///  Creates a new item, or replaces an old item with a new item.
public func putItem(_ input: PutItemInput) -> Future<PutItemOutput> {
    return client.send(operation: "PutItem",
					   path: "/",
					   httpMethod: "POST",
					   input: input)
}

^ Conditional Expressions allow you to `put` an item only if its current value satisfies a constraint.

^ Use them to prevent overwriting with the `attribute_not_exists` conditional expression

---- 


### `PutItemInput`

/// A map of attribute name/value pairs.
public let item: [String: AttributeValue]

/// Use ReturnValues if you want to get the item attributes
/// as they appeared before they were updated
public let returnValues: ReturnValue?

/// The name of the table to contain the item.
public let tableName: String


^ You must include the Primary key, but you can add many more attributes if necessary

^ Some rules: No `null` values, `String` & `Binary` must be longer than zero-length, and no empty values

^ You can return the item's attribute values in the same operation, using the ReturnValues parameter.

---- 

## Querying for Multiple Items

///  The Query operation finds items based on primary key values.
public func query(_ input: QueryInput) -> Future<QueryOutput> {
    return client.send(operation: "Query",
					   path: "/",
					   httpMethod: "POST",
					   input: input)
}


^  You can query any table or secondary index that has a composite primary key (a partition key and a sort key).  

^ A Query operation always returns a result set. If no matching items are found, the result set will be empty. 

^ Query results are always sorted by the sort key value. 

^ You can optionally narrow the scope of the Query operation by specifying a sort key value and a comparison operator in KeyConditionExpression. 

----

/// One or more substitution tokens for attribute names
/// in an expression.
public let expressionAttributeNames: [String: String]?

/// One or more values that can be substituted in an expression.
public let expressionAttributeValues: [String: AttributeValue]?

/// The condition that specifies the key values for items to
/// be retrieved by the Query action.
public let keyConditionExpression: String?

^ Use the KeyConditionExpression parameter to provide a specific value for the partition key. The Query operation will return all of the items from the table or index with that partition key value.

----

let nowDate = Date()
let earlierDate = now.addingTimeInterval(-60.0 * 60.0)

let now = formatter.string(from: nowDate)
let earlier = formatter.string(from: earlierDate)

let expressionAttributeNames = [
		"#S": "ServiceName",
		"#T": "Timestamp"]
let expressionAttributeValues = [
		":global": DynamoDB.AttributeValue(s: "global"),
		":then": DynamoDB.AttributeValue(s: earlier),
		":now": DynamoDB.AttributeValue(s: now)]

let keyConditionExpression = "#S = :global AND #T BETWEEN :then AND :now"

^ To walk us through an example, let's say we had a Secondary Index setup on `Timestamp`

^ We want to query for all the updates made within the last 60 minutes

^ We start off by defining what *names* we plan to use in our query, in this case `ServiceName` and `Timestamp`

^ Then we insert the values, we use the ISO 8601 date format.

^ Finally, we put that together in a `Key Condition` which we use to describe our constraints.

---- 

## AWS SDK Swift Dynamo Client

1. `AttributeValue`
2. `getItem` / `putItem`
3. `query`

[.build-lists: false]

^ There are some other, simpler APIs for Batch gets/puts, but that's the high-level overview.

^ However, now that we know what we do about the behavior of `PutItem`, that presents us with a problem.

----

## History of Changes
 ![]

^ When we're making changes to the button, we want to be able to maintain a historical log of changes over time.

[.footer: Photo by Daniel H. Tong on Unsplash]

----

| Service Name | Version | Is Incident Ongoing | User name | Time stamp | Message |
| --- | --- | --- | --- | --- | --- |
|  global  | 1 | true  | Jim | 8/25/2019, 2:04:31 AM | Error! |
|  global  | 2 | false   | Joe | 8/27/2019, 7:13:40 PM | Fixed |

^ This looks great, but... we don't actually have a way to get "latest value" without doing a full table scan!

^ And if we remove the `Version` field entirely, updates will overwrite the value

^ Using that data model is fine for a single value you don't want or need the history for this

----

| Service Name | Version | Is Incident Ongoing | User name | Time stamp | Message |
| --- | --- | --- | --- | --- | --- |
|  global  | 1 | true  | Jim | 8/25/2019, 2:04:31 AM | Error! |
|  global  | 2 | false   | Joe | 8/27/2019, 7:13:40 PM | Fixed |

^ This provides a challenge— when we think of something that we want a log, how could we represent this?

^ In SQL, you could just have the DB generate a new ID for you

^ Then when you are looking for the current state, look at the latest value

^ There's a setup for that with Dynamo, and Amazon has a pattern they suggest for this.

---- 

| Service Name | Version | Is Incident Ongoing | User name | Time stamp | Message | Current |
| --- | --- | --- | --- | --- | --- | --- |
|  global  | 0 | false   | Joe | 8/27/2019, 7:13:40 PM | Fixed | 2 |
|  global  | 1 | true  | Jim | 8/25/2019, 2:04:31 AM | Error! | |
|  global  | 2 | false   | Joe | 8/27/2019, 7:13:40 PM | Fixed | |

^ Here you notice we've added a new field, as well as a new "default" row at 0.

^ The row with `Version = 0` is special, it's _always_ considered the latest version.
 ^ It's also the only item with a value for `Current`; that's a pointer to the latest row.

---- 

| Service Name | Version | Is Incident Ongoing | User name | Time stamp | Message | Current |
| --- | --- | --- | --- | --- | --- | --- |
|  global  | 0 | false   | Joe | 8/27/2019, 7:13:40 PM | Fixed | 2 |
|  global  | 1 | true  | Jim | 8/25/2019, 2:04:31 AM | Error! | |
|  global  | 2 | false   | Joe | 8/27/2019, 7:13:40 PM | Fixed | |

^ When we want to make an update, we can perform a conditional `Put` on version `0` to only increment the version if the value is still `2`.

^ We can also use a transaction to add row `3` at the same time.

---- 

## 🔀 Denormalized Data

^ So the lesson I learned here was to focus on how to utilize the structures available to create an appropriate access pattern.

^ With a SQL database, you're going to create separate patterns that require completely different setups.

^ With Dynamo, whether you creating an additional Secondary Index or changing your data pattern, you're considering how your application will read your data ahead of time.
 ^ Once you set the data access patterns, they're largely locked in stone unless you add another Index (which has limits)

---- 

# Fluent DynamoDB

![photo-1496355723323-30286a0b340d]

^ We're moving up to the third and final part of the talk!

^ It's already been quite a journey.

[.footer: Photo by Will O on Unsplash]

---- 

## 💧 Fluent 3 Concepts

1. 📦 `Database`
2. 🔌 `DatabaseConnection`
3. 😻 `Provider`

![fit right]

---- 

### 📦  `Database`

public protocol Database {

    associatedtype Connection: DatabaseConnection

    /// Creates a new `DatabaseConnection` that will perform
	/// async work on the supplied `Worker`.
    func newConnection(on worker: Worker) -> Future<Connection>
}

^ Our database manages our connection.

----

public final class DynamoDatabase: Database {
    public typealias Connection = DynamoConnection
    private let config: DynamoConfiguration

    public init(config: DynamoConfiguration) {
        self.config = config
    }

    internal func openConnection() -> DynamoDB {
        return DynamoDB(accessKeyId: config.accessKeyId,
						secretAccessKey: config.secretAccessKey,
						region: config.region,
						endpoint: config.endpoint)
    }

    public func newConnection(on worker: Worker) -> EventLoopFuture<DynamoConnection> {
        do {
            let conn = try DynamoConnection(database: self, on: worker)
            return worker.future(conn)
        } catch {
            return worker.future(error: error)
        }
    }

^ The database converts our configuration (credentials & region) into a connection.

^ It also creates the AWS SDK client to Dynamo, since it receives the configuration values.

^ Our connection will ask us for a client when it's ready to spin one up.

----

##  🔌 `DatabaseConnection`

![photo-1534224039826-c7a0eda0e6b3]

[.footer: Photo by israel palacio on Unsplash]

^ The `DatabaseConnection` is what I'd consider the core to actually work with your underlying db.

^ This takes the AWS client library and makes the proper calls based on the query.

----

public protocol DatabaseConnection: DatabaseConnectable, Extendable {
    /// This connection's associated database type.
    associatedtype Database: DatabaseKit.Database
        where Database.Connection == Self
    
    /// If `true`, this connection has been closed and is no
	/// longer valid.
    /// This is used by `DatabaseConnectionPool` to prune
	/// inactive connections.
    var isClosed: Bool { get }

    /// Closes the `DatabaseConnection`.
    func close()
}

^ The `DatabaseConnection` itself is quite simple.

---- 

public final class DynamoConnection: DatabaseConnection {
    public typealias Database = DynamoDatabase

    public var isClosed: Bool {
        return self.handle.isClosed()
    }

    public func close() {
        self.handle.close()
    }

    /// Reference to parent `DynamoDatabase` that created this connection.
    private let database: DynamoDatabase

    internal private(set) var handle: DynamoDB!

    internal init(database: DynamoDatabase, on worker: Worker) throws {
        self.database = database
        self.eventLoop = worker.eventLoop
        self.handle = database.openConnection()
    }
}

^ For us, we create the client, and can make sure its underlying EventLoop can be closed.

----

## Creating a Connection

![photo-1571990775458-0fd6051bc201]

^ Let's talk about a few things we also need to create so we can actually use our `Connection` to make queries.

[.footer: Photo by Phix Nguyen on Unsplash]

----

public struct DatabaseIdentifier<D: Database>: Equatable,
	Hashable, CustomStringConvertible, ExpressibleByStringLiteral {
    /// The unique id.
    public let uid: String

    /// See `CustomStringConvertible`.
    public var description: String {
        return uid
    }

    /// Create a new `DatabaseIdentifier`.
    public init(_ uid: String) {
        self.uid = uid
    }

    /// See `ExpressibleByStringLiteral`.
    public init(stringLiteral value: String) {
        self.init(value)
    }
}


^ We need a constant which defines the name of each particular database, such as SQLite, MySQL, Postgres, or...

----

extension DatabaseIdentifier {
    /// Default identifier for `DynamoDatabase`.
    public static var dynamo: DatabaseIdentifier<DynamoDatabase> {
        return "dynamo"
    }
}

^ Dynamo

----


/// Capable of creating connections to identified databases.
public protocol DatabaseConnectable: Worker {

    func databaseConnection<Database>(
		to database: DatabaseIdentifier<Database>?) ->
		Future<Database.Connection>

}

^ You'll receive a connection by asking something that conforms to `DatabaseConnectable`.

^ This is typically going to be the Vapor `Request` object that you get once you receive an HTTP request.

----

## `DatabaseQueryable`

![photo-1557604582-d287ede3d371]

^ We're also going to conform our `DynamoConnection` to `DatabaseQueryable` so it can submit requests.

[.footer: Photo by Kirill Pershin on Unsplash]

----

public protocol DatabaseQueryable {

    associatedtype Query
    
    associatedtype Output
    
    /// Asynchronously executes a query passing zero
	/// or more output to the supplied handler.
    func query(_ query: Query,
			   _ handler: @escaping (Output) throws -> ()) ->
			Future<Void>
}

^ We need input, a `Query` and a response, or `Output`.

^ Then we just need to make sure we implement the actual query logic.

---- 

public enum DynamoQueryAction {
    case set, get, delete, filter
}

/// 🔎 A DynamoDB operation
public struct DynamoQuery {
    /// 🏹 Note this is a var so `get/set` can be flipped easily if desired
    public var action: DynamoQueryAction

    /// 🍴 The name of the table in DynamoDB to work on
    public let table: String

    /// 💸 Which value(s) to perform the action upon
    public let keys: [DynamoValue]
}

^ For FluentDynamoDB, `DynamoQuery` is the wrapper that allows us to `query`. 
^ It knows what table to send the request to, whether it's reading or writing, and what item to operate on.

----

/// 🔑 Values to uniquely identify an item stored in a DynamoDB Table
public struct DynamoValue: Codable, Equatable {

    public enum Attribute: Codable, Equatable {
        case mapping([String: Attribute])
        case null(Bool)
        case stringSet([String])
        case binary(Data)
        case string(String)
        case list([Attribute])
        case bool(Bool)
        case numberSet([String])
        case binarySet([Data])
        /// We send over all numbers to Dynamo as Strings, and cannot use Numeric
        case number(String)
}

^ When we return a value, we wrap it inside an Enum with associated values. This feels much more natural to work with.

^ We have helpers to convert to/from the underlying `AttributeValue` used by the DynamoDB library.

----


public func query(_ query: Query, _ handler: @escaping (Output) throws -> ()) -> Future<Void> {
        switch query.action {
        case .get:
            let inputItem = DynamoDB.GetItemInput(
                key: requestedKey, tableName: query.table)
            return self.handle.getItem(inputItem).map { output in
                return try handler(Output(attributes: output.item))
            }
        case .set:
            let inputItem = DynamoDB.PutItemInput(item: requestedKey, returnValues: .allOld, tableName: query.table)
            return self.handle.putItem(inputItem).map { output in
                return try handler(Output(attributes: output.attributes))
            }
        case .delete:
            let inputItem = DynamoDB.DeleteItemInput(
                key: requestedKey, returnValues: .allOld, tableName: query.table)
            return self.handle.deleteItem(inputItem).map { output in
                return try handler(DynamoValue(attributes: output.attributes))
            }
        case .filter:
            return self.eventLoop.newFailedFuture(error: DynamoConnectionError.notImplementedYet)
        }
    } catch {
        return self.eventLoop.newFailedFuture(error: error)
    }
}

^ So let's look at how to make a request. I'll zoom in to `PutItem` on the next slide.

^ For this query, we're submitting a request to DynamoDB for one value

^ We return a Future which signals completion, and the handler will run upon success.

----

case .set:
    let inputItem = DynamoDB.PutItemInput(item: requestedKey,
										  returnValues: .allOld,
										  tableName: query.table)

     return self.handle.putItem(inputItem).map { output in
     	return try handler(DynamoValue(attributes: output.attributes))
	 }

^ To look at this more closely, we're generating the `PutItemInput` and sending the request.

^ Once we receive the response, we'll convert back to `DynamoValue` and invoke the callback.

^ Fluent provides an extension which wraps this in a `Future` assuming callers prefer that route.

----

## 😻 `Provider`

public protocol Provider {
    /// Register all services you would like to provide the `Container` here.
    ///
    ///     services.register(RedisCache.self)
    ///
    func register(_ services: inout Services) throws

    /// Called before the container has fully initialized.
    func willBoot(_ container: Container) throws -> Future<Void>

    /// Called after the container has fully initialized and after `willBoot(_:)`.
    func didBoot(_ container: Container) throws -> Future<Void>
}

^ We need something to tie this together.

^ `Provider`s allow third-party services to be easily integrated into your Vapor app.

^ During startup, you register your Providers, which have access to a `Services` struct they can mutate. After all providers register, there's a boot phase.

^ Most of your "real work" that isn't registering related services should be in `didBoot`

----

/// 💧 The Provider expected to be registered to easily allow
/// usage of DynamoDB from within a Vapor application
public struct FluentDynamoDBProvider: Provider {
    public func register(_ services: inout Services) throws {
        try services.register(FluentProvider())

        services.register(DynamoConfiguration.self)
        services.register(DynamoDatabase.self)
        var databases = DatabasesConfig()
        databases.add(database: DynamoDatabase.self, as: .dynamo)
        services.register(databases)
    }
    
    public func didBoot(_ container: Container) throws -> EventLoopFuture<Void> {
        return .done(on: container)
    }
}

^ We want to make sure both the configuration and Database are available during configuration.

^ We also want to add Dynamo as an available DB.

^ Note that we're using the `.dynamo` Database Identifier.

----

try services.register(FluentDynamoDBProvider())

var databases = DatabasesConfig()

let credentialsPath = Environment.get("CREDENTIALS_FILENAME") ?? "/etc/emergency-stop.json"
let creds = awsCredentials(path: credentialsPath)
let endpoint = Environment.get("ENVIRONMENT") == "local" ? "http://localhost:8000" : nil

let dynamoConfiguration =  DynamoConfiguration(accessKeyId: creds.accessKey,
											   secretAccessKey: creds.secretKey,
											   endpoint: endpoint)


let dynamo = DynamoDatabase(config: dynamoConfiguration)
databases.add(database: dynamo, as: .dynamo)
services.register(databases)

^ We're almost there! Let's get up to Application Code!

^ We wire everything up in our `configure` function.

^ We bootstrap credentials, then create our database.

----

struct ServiceLock: Codable {
    public let serviceName: String
    public var version: Int?
    public var currentVersion: Int?
    public let isIncidentOngoing: Bool
    public let username: String
    public let timestamp: Date
    public let message: String
}

extension ServiceLock: Content { }

^ In our app, we use `Models` to interact with our persistent data.

^ Here's a very simplified version of the Red Button, the `Service Lock`.

----

/// Write a ServiceLock to DynamoDB
///
/// - Returns:
///     An `EventLoopFuture` used to indicate success or failure
public func write(on worker: Request) -> EventLoopFuture<[DynamoValue]> {

    let key = self.dynamoFormat()

    let query = DynamoQuery(action: .set,
							table: "limit-break-emergency-stop",
							keys: [key])

    return worker.databaseConnection(to: .dynamo)
		.flatMap { connection in
        	connection.query(query)
    	}
}

^ It has a method to persist its values to a row in its DynamoDB table. This is a simplified version.

^ We create a key from its properties

^ Convert that to our query, then submit the request

----

# 🥁

^ So with all of that, we can create our route to update the lock.

----

router.post { req -> Future<View> in
    return try req.content.decode(Update.self).flatMap { update in
        return ServiceLock.read(on: req,
							    serviceName: ServiceNames.global,
								version: 0).flatMap { latestLock in
            let lock = ServiceLock(serviceName: latestLock.serviceName,
								   version: latestLock.currentVersion! + 1,
								   currentVersion: nil,
								   isIncidentOngoing: update.isIncidentOngoing,
								   username: username,
								   timestamp: Date(),
								   message: update.message)
            return lock.write(on: req)
		}
	}
}

^ When we want to make an update, we'll look for the latest version by checking `Version 0`

^ Once we have that response, we can write to a row one-higher than the current version.

^ To keep this slide simple I'm not showing the transaction also updating `Version: 0`

----

# 🎉 🎉 🎉

![photo-1521334726092-b509a19597c6]

[.footer: Photo by Seth Reese on Unsplash]

----


# Next

1. ⏫ Publish `AWSSDKSwift` 4.0.0
	1. 🎉 Uses `NIO` 2.0
2. 🌄 Create `DynamoKit` with NIO 2.0
3. 💧 Convert `FluentDynamoDB` to Fluent 4
4. 🕺 Upgrade `DynamoModel`
5. ✨ Better integration with `swift-log` and `swift-metrics`

----

## Thank you!

[.build-lists: false]

* 🔴 Emergency Stop
* 📦 DynamoDB
* 🌴 `AWSSDKSwift`
* 💧 Fluent DynamoDB

### [https://github.com/Yasumoto/fluent-dynamodb]

