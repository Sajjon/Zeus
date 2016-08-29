# 🌩 Zeus 🌩
REST Client with Core Data persistence in Swift. This project is inspired by the fantastic Objective-C framework [RestKit](https://github.com/RestKit/RestKit), but this project is written in Swift.


- [x] ☁️➡📱 GET with JSON array without json key
- [x] ☁️➡📱 GET with JSON object without json key
- [x] ➡📱❓Condition for determining if incoming object should be stored
- [x] 🍎➡🍏 Value transformer, converting e.g. a `String` to an `Int` 
- [x] 🍒🍒🍒 _Cherry picker_ that enables to you chose between incoming value of existing per attribute
- [ ] 3³³ Convert Swift 3.0 (**in progress**), **estimate: small**
- [ ] 🔀🔀🔀 Nested objects, **estimate: large**
- [ ] ☁️➡📱 GET with JSON object with json key, **estimate: small**
- [ ] ☁️➡📱 GET with JSON object with json key, **estimate: small**
- [ ] 📱➡☁️ POST **estimate: large**
- [ ] 🤔💭💭 Enable in memory store (already prepared but not tested and needs more work), **estimate: large**

# Installation
Cocoapods support coming soon... 

**Zeus will require Swift 3.0**

## Configuration
Create an instance of DataStore and ModelManager and setup your mappings. Preferably this can be put into some `ZeusConfigurator` class, e.g.
```swift
import Foundation
import Zeus

private let baseUrl = "http://anapioficeandfire.com/api/"
class ZeusConfigurator {

    var store: DataStoreProtocol!
    var modelManager: ModelManagerProtocol!

    init() {
        setup()
    }

    fileprivate func setup() {
        setupCoreDataStack()
        setupLogging()
        setupMapping()
    }

    fileprivate func setupLogging() {
        Zeus.logLevel = .Warning
    }

    fileprivate func setupCoreDataStack() {
        store = DataStore()
        modelManager = ModelManager(baseUrl: baseUrl, store: store)
        DataStore.sharedInstance = store
        ModelManager.sharedInstance = modelManager
    }

    fileprivate func setupMapping() {
        modelManager.map(Character.entityMapping(store), House.entityMapping(store)) {
            character, house in
            character == Router.characters
            character == Router.characterById(nil)
            house == Router.houses
            house == Router.houseById(nil)
        }
    }
}

```

Then you can create an instance of this class in the `application:didFinishLaunchingWithOptions` method in your `AppDelegate` class.

```swift
import UIKit
import Zeus
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder {

    static var sharedInstance: AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }
    static var modelManager: ModelManagerProtocol {
        return sharedInstance.zeusConfig.modelManager
    }
    var zeusConfig: ZeusConfigurator!
    var window: UIWindow?

}

extension AppDelegate: UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: Any]?) -> Bool {
        zeusConfig = ZeusConfigurator()
        return true
    }
}

```

# Mapping

You create a mapping between the JSON response from the backend server and your models using a `Dictionary<String, String>`. The model can either be an NSManagedObject subclass or a PONSO (_Plain Old NSObject_) (support is currently underway...).

The mappings are added to the `ModelManagerProtoco` using the `map` function taking instances of `Mapping` conforming to `MappingProtocol` as input. This mappings are easily created by letting your Swift classes that model your `Entities` implement the `MappableEntitiy` protocol.

In the example project a superclass for all NSManagedObject classes is used, called `ManagedObject` implementing the `MappableEntity` protocol:

```swift
import Foundation
import CoreData
import Zeus

let mustOverride = "must override"
class ManagedObject: NSManagedObject, MappableEntity {

    class var destinationClass: NSObject.Type {
        return self
    }
    class var idAttributeName: String { fatalError(mustOverride) }
    class var attributeMapping: AttributeMappingProtocol { fatalError(mustOverride) }
    class var transformers: [TransformerProtocol]? { return nil }
    class var cherryPickers: [CherryPickerProtocol]? { return nil }
    class var shouldStoreModelCondtions: [ShouldStoreModelConditionProtocol]? { return nil }
    class func futureConnections(forMapping mapping: MappingProtocol) -> [FutureConnectionProtocol]? {return nil}
}
```
Then it is super easy to create you model mappings, the `Character` class looks like this:
```swift
import Foundation
import CoreData
import Zeus

class Character: ManagedObject {
    @NSManaged var characterId: String?
    @NSManaged var name: String
    @NSManaged var gender: String?

    override class var idAttributeName: String {
        return "characterId"
    }

    override class var attributeMapping: AttributeMappingProtocol {
        return AttributeMapping(mapping: [
            "url" : "characterId",
            "name": "name",
            "gender": "gender"
        ])
    }
}

```

# Fetching data (HTTP GET)
You fetch your data using the `get:atPath:queryParams:options:done` method on the `ModelManagerProtocol`. If you want to fetch all the Game of Thrones houses from the [Example project](#Example) you can do that like this:
```swift
    func getHouses() {
        Zeus.HTTPClient.sharedInstance.get(atPath: "houses", queryParameters: nil, options: nil) {
            result in
            if let error = result.error {
                print("Error fetching houses, error: \(error)")
            } else if let houses = result.data as? [House] {
                print("successfully fetched #\(houses.count) houses")
            }
        }
    }
```

# Examples
Test the ApiOfIceAndFire project included in this repo

