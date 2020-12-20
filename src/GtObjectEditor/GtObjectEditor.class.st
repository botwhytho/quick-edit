Class {
	#name : #GtObjectEditor,
	#superclass : #Object,
	#instVars : [
		'object'
	],
	#category : #'GtObjectEditor-Core'
}

{ #category : #example }
GtObjectEditor class >> ArrayAtRootExample [
	"Sample from 'https://jsonplaceholder.typicode.com/posts' (slice of first five)"

	<gtExample>
	| arr |
	arr := '[
	{
		"userId" : 1,
		"title" : "sunt aut facere repellat provident occaecati excepturi optio reprehenderit",
		"id" : 1,
		"body" : "quia et suscipit\nsuscipit recusandae consequuntur expedita et cum\nreprehenderit molestiae ut ut quas totam\nnostrum rerum est autem sunt rem eveniet architecto"
	},
	{
		"userId" : 1,
		"title" : "qui est esse",
		"id" : 2,
		"body" : "est rerum tempore vitae\nsequi sint nihil reprehenderit dolor beatae ea dolores neque\nfugiat blanditiis voluptate porro vel nihil molestiae ut reiciendis\nqui aperiam non debitis possimus qui neque nisi nulla"
	},
	{
		"userId" : 1,
		"title" : "ea molestias quasi exercitationem repellat qui ipsa sit aut",
		"id" : 3,
		"body" : "et iusto sed quo iure\nvoluptatem occaecati omnis eligendi aut ad\nvoluptatem doloribus vel accusantium quis pariatur\nmolestiae porro eius odio et labore et velit aut"
	},
	{
		"userId" : 1,
		"title" : "eum et est occaecati",
		"id" : 4,
		"body" : "ullam et saepe reiciendis voluptatem adipisci\nsit amet autem assumenda provident rerum culpa\nquis hic commodi nesciunt rem tenetur doloremque ipsam iure\nquis sunt voluptatem rerum illo velit"
	},
	{
		"userId" : 1,
		"title" : "nesciunt quas odio",
		"id" : 5,
		"body" : "repudiandae veniam quaerat sunt sed\nalias aut fugiat sit autem sed est\nvoluptatem omnis possimus esse voluptatibus quis\nest aut tenetur dolor neque"
	}
]'.
	^ GtObjectEditor new object: (NeoJSONReader fromString: arr)
]

{ #category : #example }
GtObjectEditor class >> DictionaryAtRootExample [
	"Sample from https://httpbin.org/json"

	<gtExample>
	| dict |
	dict := '{
	"slideshow" : {
		"author" : "Yours Truly",
		"date" : "date of publication",
		"slides" : [
			{
				"title" : "Wake up to WonderWidgets!",
				"type" : "all"
			},
			{
				"items" : [
					"Why <em>WonderWidgets</em> are great",
					"Who <em>buys</em> WonderWidgets"
				],
				"title" : "Overview",
				"type" : "all"
			}
		],
		"title" : "Sample Slide Show"
	}
}'.
	^ GtObjectEditor new object: (NeoJSONReader fromString: dict)
]

{ #category : #parsing }
GtObjectEditor >> destringify: aValue [
	"BrEditableLabel holds roped text. This tries to convert back to a valid JSON atomic data type (using nil instead of null because Pharo)"

	^ #(true false nil)
		detect: [ :each | each asString = aValue ]
		ifNone: [ Number readFrom: aValue ifFail: [ aValue ] ]
]

{ #category : #'view updating' }
GtObjectEditor >> editingView: aView [
	<gtView>
	| view associate |
	associate := [ :x :i | i -> x ].
	view := aView columnedTree
		title: 'Edit';
		priority: 1;
		items: [ self object isArray
				ifTrue: [ self object collectWithIndex: associate ]
				ifFalse: [ self object associations ] ];
		children: [ :each | 
			| item |
			item := each value.
			item isDictionary
				ifTrue: [ item associations ]
				ifFalse: [ item isArray
						ifTrue: [ item collectWithIndex: associate ]
						ifFalse: [ #() ] ] ];
		column: 'Key' text: #key;
		column: 'Value'
			icon: [ :each | 
			| item |
			item := each value.
			(item isDictionary or: [ item isArray ])
				ifTrue: [ BlTextElement new text: '' asRopedText ]
				ifFalse: [ BrEditableLabel new
						look: BrGlamorousEditableLabelLook new glamorousRegularFontAndSize;
						text: item;
						when: BrEditorAcceptWish
							do: [ :aWish | each value: (self destringify: aWish text asString) ] ] ];
		send: #value;
		expandUpTo: 1.
	view columns second weight: 1.
	^ view
]

{ #category : #accessing }
GtObjectEditor >> object [
	^ object
]

{ #category : #accessing }
GtObjectEditor >> object: anObject [
	object := anObject
]