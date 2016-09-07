{
	"id" : 237,
	"tracks" : {
		"items" : [
			{
				"id" : 123,
				"name" : "A great song"
				"duration" : "180"
			},
			{
				"id" : 124,
				"name" : "A bad song",
				"duration" : "240"
			}
		],
		"release_date" : "2016-09-06",
		"numberOfTracks" : "200" //pagination
	},
	"images" : [
		{
			"lowRes" : "http://....1.small.png"
			"highRes" : "http://....1.large.png"
		},
		{
			"lowRes" : "http://....2.small.png"
			"highRes" : "http://....2.large.png"
		}
	],
	"available_markets" : ["SE", "EN"],
	"record_company" : "A prehistoric institute" // We dont want to store this
}

class Album {
	//MARK: Attributes
	var albumId: Int
	var releaseDate: NSDate
	var trackCount: Int
	var availableMarkets: [String] // Transformable

	//MARK: Relationships
	var images: [Image]
	var tracks: [Track]

	//MARK: Mapping
	var idAttributeNamed: String { return "albumId" }

	var attributes: AttributeMappingJson {
		return [
			"id" : "albumId",
			"tracks.release_date" : "releaseDate",
			"tracks.numberOfTracks" : "trackCount",
			"available_markets" : "availableMarkets"
		]
	}

	var relationships: [Relationship] {
		return [
			Relationship<Image>(named: "images", jsonKey: "images"),
			Relationship<Track>(named: "tracks", jsonKey: "tracks.items")
		]
	}

	// NSDate should implicitly transform...
	var transformers: [Transformer] {
		return [ToInt(attributeName: "trackCount")]
	}

	var cherryPickers: [cherryPicker] {
		return [cherryPicker(attributeName: "availableMarkets") {
			incoming: NSObject, current: NSObject?
			return  (incoming.count > current.count) ? incoming : current 
		}]
	}
}

class Track {
	var trackId: Int
	var name: String
	var duration: Float
	
	//MARK: Mapping
	var idAttributeNamed: String { return "trackId" }

	var attributes: AttributeMappingJson {
		return ["id" : "trackId"," name" : "name", "duration" : "duration"]
	}

	var transformers: [Transformer] {
		return [ToFloat(attributeName: "duration")]
	}

	var storeConditions: [StoreModelCondition] {
		return [Condition(attributeName: "name") {
			value in
			return value.contains("bad")
		}]
	}
}

class Image {
	var small: String
	var large: String

	//MARK: Mapping
	var idAttributeNamed: String { return "small" }

	var attributes: AttributeMappingJson {
		return ["lowRes" : "small", "highRes" : "large"]
	}
}

/// Prune and flatten JSON. Translate JSON keys to attribute/property names/keys
{
	"albumId" : 237,
	"tracks" : [
		{
			"trackId" : 123,
			"name" : "A great song"
			"duration" : "180"
		},
		{
			"trackId" : 124,
			"name" : "A bad song",
			"duration" : "240"
		}
	],
	"releaseDate" : "2016-09-06",
	"numberOfTracks" : "200" //pagination
	"images" : [
		{
			"small" : "http://....1.small.png"
			"large" : "http://....1.large.png"
		},
		{
			"small" : "http://....2.small.png"
			"large" : "http://....2.large.png"
		}
	],
	"availableMarkets" : ["SE", "EN", "GE", "FI"] // Longer found in DB
}
Relationship<Image>(named: "images", jsonKey: "images"),
Relationship<Track>(named: "tracks", jsonKey: "tracks")

/// Apply implicit and explicit tranformations
{
	"albumId" : 237,
	"tracks" : [
		{
			"trackId" : 123,
			"name" : "A great song"
			"duration" : 180.0
		},
		{
			"trackId" : 124,
			"name" : "A bad song",
			"duration" : 240.0
		}
	],
	"releaseDate" : 432892318,
	"numberOfTracks" : 200 //pagination
	"images" : [
		{
			"small" : "http://....1.small.png"
			"large" : "http://....1.large.png"
		},
		{
			"small" : "http://....2.small.png"
			"large" : "http://....2.large.png"
		}
	],
	"availableMarkets" : ["SE", "EN"]
}

/// Cherry Pick
{
	"albumId" : 237,
	"tracks" : [
		{
			"trackId" : 123,
			"name" : "A great song"
			"duration" : 180.0
		},
		{
			"trackId" : 124,
			"name" : "A bad song",
			"duration" : 240.0
		}
	],
	"releaseDate" : 432892318,
	"numberOfTracks" : 200 //pagination
	"images" : [
		{
			"small" : "http://....1.small.png"
			"large" : "http://....1.large.png"
		},
		{
			"small" : "http://....2.small.png"
			"large" : "http://....2.large.png"
		}
	],
	"availableMarkets" : ["SE", "EN"],
}
