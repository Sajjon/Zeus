{
	"id" : 237,
	"inner" : {
		"items" : [
			{
				"name" : "saveMe"
				"value" : "79.5"
			},
			{
				"name" : "ignoreMe",
				"value" : "123.7"
			}
		],
		"createdAt" : "2016-09-06",
		"numberOfItems" : "200"
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
	"fibSeq" : [1, 2, 3, 5],
	"keyForIrrelevantValue" : "This value is irrelevant"
}

class MyModel {
	
	var modelId: Int
	var createdAt: NSDate
	var itemServerCount: Int
	var fibonacci: [Int] // Transformable
	//relations
	var images: [Image]
	var items: [Inner]

	var idAttributeNamed: String { return "modelId" }

	var attributes: AttributeMappingJson {
		return [
			"id" : "modelId",
			"inner.createdAt" : "createdAt",
			"inner.numberOfItems" : "itemServerCount",
			"fibSeq" : "fibonacci"
		]
	}

	var relations: [Relationship] {
		return [
			Relationship(source: "images", destination: "images", mapping: Images.mapping),
			Relationship(source: "inner.items", destination: "items", mapping: Inner.mapping)
		]
	}

	// NSDate should implicitly transform...
	var transformers: [Transformer] {
		return [ToFloat(attributeName: "value"), ToInt(attributeName: "itemServerCount")]
	}

	var cherryPickers: [cherryPicker] {
		return [cherryPicker(attributeName: "fibonacci") {
			incoming: NSObject, current: NSObject?
			return  (incoming.count > current.count) ? incoming : current 
		}]
	}
}

class Inner {
	var name: String
	var value: Double

	var attributes: AttributeMappingJson {
		return ["name" : "name", "value" : "value"]
	}

	var transformers: [Transformer] {
		return [ToFloat(attributeName: "value")]
	}

	var storeConditions: [StoreModelCondition] {
		return [Condition(attributeName: "name") {
			value in
			return value != "ignoreMe"
		}]
	}
}

class Image {
	var small: String
	var large: String

	var attributes: AttributeMappingJson {
		return ["lowRes" : "small", "highRes" : "large"]
	}
}

/// Prune, flatten and translate keys to property keys
{
	"id" : 237,
	"items" : [
		{
			"name" : "saveMe"
			"value" : "79.5"
		},
		{
			"name" : "ignoreMe",
			"value" : "123.7"
		}
	],
	"createdAt" : "2016-09-06",
	"itemServerCount" : "200"
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
	"fibonacci" : [1, 2, 3, 5]
}
relationships: [
	Relationship(source: "images", destination: "images", mapping: Images.mapping),
	Relationship(source: "items", destination: "items", mapping: Inner.mapping)	
]

/// Apply implicit and explicit tranformations
{
	"id" : 237,
	"items" : [
		{
			"name" : "saveMe"
			"value" : 79.5
		},
		{
			"name" : "ignoreMe",
			"value" : 123.7
		}
	],
	"createdAt" : 12345,
	"itemServerCount" : 200
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
	"fibonacci" : [1, 2, 3, 5]
}

/// Cherry Pick
{
	"id" : 237,
	"items" : [
		{
			"name" : "saveMe"
			"value" : 79.5
		},
		{
			"name" : "ignoreMe",
			"value" : 123.7
		}
	],
	"createdAt" : 12345,
	"itemServerCount" : 200
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
	"fibonacci" : [1, 2, 3, 5, 8, 13, 21] // Longer found in DB
}
relationships: [
	Relationship(source: "images", destination: "images", mapping: Images.mapping),
	Relationship(source: "items", destination: "items", mapping: Inner.mapping)	
]

/// Perform mapping
func performMapping(mapping, parsedJson?) -> Result {
	guard let parsedJson = parsedJson else { return  }
	switch parsedJson {}
	case .array(let array):
		return model(fromArray: array)
	case .object(let object):
		return model(fromObject object)
	}
}

func mapChild(in model: Model, forRelationship: relationship) {
	let child = performMapping(mapping, parsedJson)
	model.setValue(relationship.name, child)
}

func model(fromArray: [JSON]) -> Result {
	var models = []
	for json in array {
		let model = model(fromObject: json)
		switch model {
		case .succes(let model):
			models.append(model)
		case .failulre(let error):
			break
		}
	}
	return Result
}

func model(fromObject: JSON) -> Result {
	let result = mapperWorker.model(json)
	switch result {
		case .success(let model):
			mapChildren(model)
		default: break
	}
	return result
}

func mapChildren(in model: Model, json) {
	guard if let relationships = mapping.relationships else { return }
	for relationship in relationships {
		mapChild(in: model, forRelationship: relationship)
	}
}
