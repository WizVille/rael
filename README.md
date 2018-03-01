# Rael

Rael is an explicit way to import, export and clone active record tree.

## Public Methods

```
# Export origin node following the schema
data_tree = Rael.export(origin, schema)

# Import data_tree in the destination node
Rael.import(data_tree, destination)

# Clone origin node in destination node following the schema
Rael.clone(origin, schema, destination)
```

## Origin

Origin is the root node you want to explore, it must be a model instance or an array of model instances.

## Destination

Origin is the root node where you want to import data, it must be a model instance or nil.

## Schema

The schema is an hash style way to describe an active record tree. A schema is a tree of node, each node is a hash that correspond to a model, hash may be composed of 4 keys:

* static: an array which contains attributes you want to export from model
* translated: an array which contains transalted attributes (globalize) you want to export from model
* foreign: a hash which list relations with other nodes you want to explore
* options: extra options about the node
	- foreign_key_in_parent: the foreign key is inside the parent instead of the child

Here is an example:

```
# An example of a questionnaire_page
# questionnaire_page has many questions
# questionnaire_page has one preference
# preference has one question
# preference has one account

schema = Rael::Schema.new("questionnaire_page", {
	:static => [ :position, :illustration, :created_at ],
	:translated => [ :title ],
	:foreign => {
	  :questions => {
	    :static => [ :position ],
	    :translated => [ :content ]
	  },
	  :preference => {
	    :static => [ :timeout ],
	    :foreign => {
	      :first_question => {
	        :options => { :foreign_key_in_parent => true },
	        :static => [ :position ],
	        :translated => [ :content ]
	      },
	      :account => {
	        :static => [ :unique_id ]
	      }
	    }
	  }
	}
})

page_1 = QuestionnairePage.find(1)
page_2 = QuestionnairePage.find(2)

Rael.clone(page_1, schema, page_2)
```

## Misc

* Active Record belongs_to / has_many / has_one must be present in model according to schema
* If an import failed, importer will try to revert any action performed
* Any error send a Rael::Error
* If you want to run the test suite, you have to set correct credientials in function "connect_ac"

## Why Rael ?

Because it clones things : )
