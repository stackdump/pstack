from pyld import jsonld
import json
import sys

doc = {
    "http://schema.org/name": "Manu Sporny",
    "http://schema.org/url": {"@id": "http://manu.sporny.org/"},
    "http://schema.org/image": {"@id": "http://manu.sporny.org/images/manu.png"}
}

context = {
    "name": "http://schema.org/name",
    "homepage": {"@id": "http://schema.org/url", "@type": "@id"},
    "image": {"@id": "http://schema.org/image", "@type": "@id"}
}

# compact a document according to a particular context
# see: http://json-ld.org/spec/latest/json-ld/#compacted-document-form
compacted = jsonld.compact(doc, context)


print(json.dumps(compacted, indent=2))
# Output:
# {
#   "@context": {...},
#   "image": "http://manu.sporny.org/images/manu.png",
#   "homepage": "http://manu.sporny.org/",
#   "name": "Manu Sporny"
# }

# REVIEW: html layout
# compact using URLs
# FIXME this pulls /doc from nginx - what needs to be there?
jsonld.compact('http://nginx/doc', 'http://nginx/context')

sys.exit() # KLUDGE: Try out all other types
# expand a document, removing its context
# see: http://json-ld.org/spec/latest/json-ld/#expanded-document-form
expanded = jsonld.expand(compacted)

print(json.dumps(expanded, indent=2))
# Output:
# [{
#   "http://schema.org/image": [{"@id": "http://manu.sporny.org/images/manu.png"}],
#   "http://schema.org/name": [{"@value": "Manu Sporny"}],
#   "http://schema.org/url": [{"@id": "http://manu.sporny.org/"}]
# }]

# expand using URLs
jsonld.expand('http://example.org/doc')

# flatten a document
# see: http://json-ld.org/spec/latest/json-ld/#flattened-document-form
flattened = jsonld.flatten(doc)
# all deep-level trees flattened to the top-level

# frame a document
# see: http://json-ld.org/spec/latest/json-ld-framing/#introduction
framed = jsonld.frame(doc, frame)
# document transformed into a particular tree structure per the given frame

# normalize a document using the RDF Dataset Normalization Algorithm
# (URDNA2015), see: http://json-ld.github.io/normalization/spec/
normalized = jsonld.normalize(
    doc, {'algorithm': 'URDNA2015', 'format': 'application/n-quads'})
# normalized is a string that is a canonical representation of the document
# that can be used for hashing, comparison, etc.1
