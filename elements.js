/*
Build statistics from elements.json.
Download last elements by elements.sh.
Tags calculated from nodes only.
*/

const fs = require('fs')
const file = fs.readFileSync('./BTCMap/elements.json')
const elements = JSON.parse(file)

const keys = new Map()
let types = new Map()
let tags = new Map()

const grabbedTags = {}
const tagsToGrab = [
  'amenity',
  'shop',
  'cuisine',
  'tourism',
  'sport',
  'company',
  'building',
  'healthcare',
  'craft',
  'leisure',
  'office',
  'place'
]

function fillKeys(obj, keys) {
  for (const key in obj) {
    if (typeof obj[key] === 'object' && key !== 'tags') {
      if (!keys.has(key)) {
        keys.set(key, new Map())
      }

      if (Array.isArray(obj[key])) {
        for (const item of obj[key]) {
          fillKeys(item, keys.get(key))
        }
      } else {
        fillKeys(obj[key], keys.get(key))
      }
    } else {
      keys.set(key, undefined)
    }
  }
}

for (const element of elements) {
  fillKeys(element, keys)

  const type = element.data.type
  types.set(type, (types.get(type) ?? 0) + 1)

  if (type === 'node') {
    for (const tag in element.data.tags) {
      tags.set(tag, (tags.get(tag) ?? 0) + 1)

      if (tagsToGrab.includes(tag)) {
        if (!grabbedTags[tag]) grabbedTags[tag] = new Map()
        const value = element.data.tags[tag]
        grabbedTags[tag].set(value, (grabbedTags[tag].get(value) ?? 0) + 1)
      }
    }
  }
}

const total = elements.length
console.log('Total elements:', total)
types = Array.from(types.entries()).sort((a, b) => b[1] - a[1])
for (const type of types) {
  console.log(`  ${type[0]}:`, type[1], `${(type[1] / total).toFixed(2)}%`)
}

function logKeys(keys, indent) {
  for (const key of keys.keys()) {
    console.log(`${indent}${key}`)
    if (keys.get(key)) {
      logKeys(keys.get(key), indent + '  ')
    }
  }
}

console.log()
console.log('Element structure:')
logKeys(keys, '  ')

console.log()
console.log('Tags:')
tags = Array.from(tags.entries()).sort((a, b) => b[1] - a[1])
for (const tag of tags) {
  console.log(`  ${tag[0]}:`, tag[1])
}

for (const tag in grabbedTags) {
  console.log()
  console.log(`Tag '${tag}':`)
  const values = Array.from(grabbedTags[tag].entries()).sort((a, b) => b[1] - a[1])
  for (const value of values) {
    console.log(`  ${value[0]}:`, value[1])
  }
}
