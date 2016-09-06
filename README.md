# 🌩 Zeus 🌩
Written in Swift 3, heaviliy inspired by [RestKit](https://github.com/RestKit/RestKit) and powered by [Alamofire](https://github.com/Alamofire/Alamofire) Zeus is a REST Client with Core Data persistence. 

You can consume your RESTful API and persist the data in Core Data without having to write any Core Data or HTTP code. You just create classes (that has to inherit from `NSObject`) and add a couple of lines of code to descibe the model, implement a simple APIClient with a couple lines of code, and then you are all setup!

## Road map
- [x] ⬇ GET with JSON object or array with or without json key
- [x] ❓Condition for determining if incoming object should be stored
- [x] 🔮 Value transformer, converting e.g. a `String` to an `Int` 
- [x] 🍒 _Cherry picker_ that enables to you chose between incoming value of existing per attribute
- [x] 🔀 Nested objects
- [ ] 💭 Enable in memory store (already prepared but not tested and needs more work), **In progress**
- [ ] ⬆ POST **estimate: large**

# Installation
Cocoapods support coming soon... 

**Zeus requires Swift 3.0**

## Configuration
Create an instance of DataStore and ModelManager and setup your mappings. Preferably this can be put into some `ZeusConfigurator` class, e.g.
```swift
import Foundationimport Zeus

private let baseUrl = "https://api.spotify.com/v1/"
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
        modelManager.map(Artist.entityMapping(store), Album.entityMapping(store)) {
            artist, album in
            artist == APIPath.artistById(noId)
            album == APIPath.albumById(noId)
            album == APIPath.albumsByArtist(noId) << "items"
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

Let your NSManagedObject classes conform to the protocol called `MappableEntity`:

```swift
public protocol Mappable {
    static var destinationClass: NSObject.Type { get }
    static var idAttributeName: String { get }
    static var attributeMapping: AttributeMappingProtocol { get }

    static func relationships(store: DataStoreProtocol) -> [RelationshipMappingProtocol]?

    static var transformers: [TransformerProtocol]? { get }
    static var cherryPickers: [CherryPickerProtocol]? { get }
    static var shouldStoreModelCondtions: [ShouldStoreModelConditionProtocol]? { get }
    static func futureConnections(forMapping mapping: MappingProtocol) -> [FutureConnectionProtocol]?
    static func mapping(_ store: DataStoreProtocol) -> MappingProtocol
}

public protocol MappableEntity: Mappable {
    static func entityMapping(_ store: DataStoreProtocol) -> EntityMappingProtocol
}
```
Then it is super easy to create you model mappings, the `Album` class looks like this:
```swift
import Zeus

extension Album {

    @NSManaged public var name: String
    @NSManaged public var availableMarkets: [String]
    @NSManaged public var albumId: String
    @NSManaged public var uri: String
    @NSManaged public var href: String

    // Optional
    @NSManaged public var popularityRaw: NSNumber?
    @NSManaged public var releaseDate: NSDate?

    // Relationships
    @NSManaged public var artistsSet: NSSet?
    @NSManaged public var imagesSet: NSSet?
    @NSManaged public var tracksOrderedSet: NSOrderedSet?

}

extension Album: MappableEntity {

    class var destinationClass: NSObject.Type {
        return self
    }

    class var idAttributeName: String {
        return "albumId"
    }

    class var attributeMapping: AttributeMappingProtocol {
        return AttributeMapping(mapping: [
            "id": "albumId",
            "name": "name",
            "available_markets": "availableMarkets",
            "href": "href",
            "uri" : "uri",
            "release_date" : "releaseDate",
            "popularity": "popularityRaw"
            ])
    }

    class func relationships(store: DataStoreProtocol) -> [RelationshipMappingProtocol]? {
        let images = RelationshipMapping(sourceKeyPath: "images", destinationKeyPath: "imagesSet", mapping: Image.entityMapping(store))
        let tracks = RelationshipMapping(sourceKeyPath: "tracks.items", destinationKeyPath: "tracksOrderedSet", mapping: Track.entityMapping(store))
        return [images, tracks]
    }
}

```

# Fetching data (HTTP GET)
You fetch your data using the `get:atPath:queryParams:options:done` method on the `ModelManagerProtocol`. If you want to fetch an album from the [Example project](#Example) you can do that like this:
```swift
     func getAlbum(byId id: String, queryParams: QueryParameters?, done: Done?) {
        Zeus.HTTPClient.sharedInstance.get(atPath: .albumById(id), queryParams: queryParams, options: nil, done: done)
    }
```

# Examples
Test the SpotifyAPI or the ApiOfIceAndFire project included in this repo.

