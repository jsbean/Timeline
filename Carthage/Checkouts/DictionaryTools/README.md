# DictionaryTools
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![Build Status](https://travis-ci.org/dn-m/DictionaryTools.svg?branch=master)](https://travis-ci.org/dn-m/DictionaryTools) 

<a name="integration"></a>
## Integration

### Carthage
Integrate **DictionaryTools** into your OSX or iOS project with [Carthage](https://github.com/Carthage/Carthage).

1. Follow [these instructions](https://github.com/Carthage/Carthage#installing-carthage) to install Carthage, if necessary.
2. Add `github "dn-m/DictionaryTools"` to your [Cartfile](https://github.com/Carthage/Carthage/blob/master/Documentation/Artifacts.md#cartfile) 
3. Follow [these instructions](https://github.com/Carthage/Carthage#adding-frameworks-to-an-application) to integrate **DictionaryTools** into your OSX or iOS project.

***

## Contents
- [OrderedDictionary](#ordered_dictionary)
- [KeyPath](#key_path)
- [DictionaryExtensions](#dictionary_extensions)

***

<a name="ordered_dictionary"></a>
## OrderedDictionary

Best of both worlds of `Array` and `Dictionary`

#### Associated Types
- `K: Hashable`
- `V: Equatable`

#### Initializers
| Name | Signature |
|------|-----------|
|**`default`**| `init()` |

##### Usage
>```Swift
>var orderedDict = OrderedDictionary<String, String>()
>```

#### Instance Methods
| Name | Signature |
|------|-----------|
|**`insertValue`**|`mutating func insert(value: V, forKey: K, atIndex: Int)`|
|**`appendValue`**|`mutating func append(value: V, forKey: K)`|
|**`appendContentsOfOrderedDictionary`**|`mutating func appendContentsOf(`<br>&nbsp;&nbsp;`orderedDictionary: OrderedDictionary<K,V>)`|

>```Swift
>orderedDict.insert("value", forKey: "key", atIndex: 0) 
>orderedDict.insert("newValue", forKey: "anotherKey", atIndex: 0) 
>orderedDict.append("newestValue", forKey: "newestKey")
>```
>```Swift
> // ["newKey": "newValue", "key": "value", "newestKey": "newestValue"]
>```

#### Subscript

| Name | Signature |
|------|-----------|
| **`index`**|`subscript(index: Int) -> V?`|
| **`key`**|`subscript(key: K) -> V?`|

>**`get`**
>```Swift
>orderedDict["key"] // -> "value"
>orderedDict[0] // -> "newValue"
>```
>**`set`**
>```Swift
>orderedDict["yetAnotherKey"] = "yetAnotherValue"
>orderedDict[3] // "yetAnotherValue"
>```

#### Instance Variables
| Name | Signature |
|------|-----------|
|**`keys`**| `keys: [K]` |
|**`values`**| `values: [K:V]` |

***

<a name="key_path"></a>
## KeyPath

Utility for retrieving values for arbitrarily deep, `String`-keyed `Dictionaries`

#### Instance Variables
| Name | Signature |
|------|-----------|
|**`keys`**| `keys: [String]` |
|**`count`**| `count: Int` |

#### Initializers

| Name | Signature |
|------|-----------|
|**`[String]`**| `init(_ keys: [String])`|
|**`String...`** | `init(_ keys: String...)`|
|**`String`** |`init(_ string: String)` |

>```Swift
>let keyPath = KeyPath(["key", "subkey", "subsubkey"])
>let keyPath = KeyPath("key", "subkey", "subsubkey")
>let keyPath = KeyPath("key.subkey.subsubkey")
>```

*** 

<a name="dictionary_extensions"></a>
## Dictionary Extensions

Extensions for the Swift `Dictionary` struct given value constraints.

#### `extension` [**`Dictionary`**](http://swiftdoc.org/v2.1/type/Dictionary/) `where Value:` [**`_ArrayType`**](http://swiftdoc.org/v2.0/protocol/_ArrayType/)

Extensions for `Dictionary` with structure: `[Hashable: [Any]]`

#### Instance Methods
| Name | Signature |
|------|-----------|
| **`ensureValueForKey`** | `mutating func ensureValueFor(key: Key)`|
| **`safelyAppendValue`** | `mutating func safelyAppend(`<br>&nbsp;&nbsp;`value: Value.Generator.Element, toArrayWithKey: Key)` |
| **`safelyAppendContentsOfOrderedDictionary`** | `mutating func safelyAppendContentsOf(`<br>&nbsp;&nbsp;`values: Value, toArrayWithKey: Key)` |

#### `extension` [**`Dictionary`**](http://swiftdoc.org/v2.1/type/Dictionary/) `where` <br>&nbsp;&nbsp;`Value:` [**`_ArrayType`**](http://swiftdoc.org/v2.0/protocol/_ArrayType/), <br>&nbsp;&nbsp;`Value.Generator.Element: ` [**`Equatable`**](http://swiftdoc.org/v2.1/protocol/Equatable/)

Extensions for `Dictionary` with structure: `[Hashable: [Equatable]]`

#### Instance Methods
| Name | Signature |
|------|-----------|
| **`safelyAndUniquelyAppendValue`** | `mutating func safelyAndUniquelyAppend(`<br>&nbsp;&nbsp;`value: Value.Generator.Element, toArrayWithKey key: Key)`|

#### `extension` [**`Dictionary`**](http://swiftdoc.org/v2.1/type/Dictionary/) `where`<br>&nbsp;&nbsp;`Key:` [**`Hashable`**](http://swiftdoc.org/v2.1/protocol/Hashable/),<br>&nbsp;&nbsp;`Value:` [**`DictionaryLiteralConvertible`**](http://swiftdoc.org/v2.1/protocol/DictionaryLiteralConvertible/),<br>&nbsp;&nbsp;`Value.Key:` [**`Hashable`**](http://swiftdoc.org/v2.1/protocol/Hashable/),<br>&nbsp;&nbsp;`Value.Value: Any`

Extensions for `Dictionary` with structure: `[Hashable: [Hashable: Any]]`

#### Instance Methods
| Name | Signature |
|------|-----------|
| **`updateValue`** | `mutating func updateValue(value: Value.Value, forKeyPath keyPath: KeyPath)` |
| **`mergeWithDictionary`** | `mutating func mergeWith(dictionary: Dictionary<Key, Value>)`|

#### `extension` [**`Dictionary`**](http://swiftdoc.org/v2.1/type/Dictionary/) `where`<br>&nbsp;&nbsp;`Key:` [**`Hashable`**](http://swiftdoc.org/v2.1/protocol/Hashable/),<br>&nbsp;&nbsp;`Value:`   [**`DictionaryLiteralConvertible`**](http://swiftdoc.org/v2.1/protocol/DictionaryLiteralConvertible/),<br>&nbsp;&nbsp;`Value.Key:` [**`Hashable`**](http://swiftdoc.org/v2.1/protocol/Hashable/),<br>&nbsp;&nbsp;`Value.Value:`  [**`_ArrayType`**](http://swiftdoc.org/v2.0/protocol/_ArrayType/)

Extensions for `Dictionary` with structure: `[Hashable: [Hashable: [Any]]]`.

#### Instance Methods
| Name | Signature |
|------|-----------|
| **`ensureValueForKeyPath`** | `func ensureValueFor(keyPath: KeyPath)` |
| **`safelyAppendValue`** | `safelyAppend(value: Value.Value.Generator.Element, toArrayWithKeyPath keyPath: KeyPath)` |
