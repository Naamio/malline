# Malline

[![Swift Package Manager](https://img.shields.io/badge/spm-compatible-brightgreen.svg?style=flat)](https://swift.org/package-manager)
[![macOS](https://img.shields.io/badge/os-macOS-green.svg?style=flat)]()
[![Linux](https://img.shields.io/badge/os-linux-green.svg?style=flat)]()
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg?style=flat)](https://opensource.org/licenses/MIT)
[![Twitter: @omnijarstudio](https://img.shields.io/badge/contact-@omnijarstudio-blue.svg?style=flat)](https://twitter.com/omnijarstudio)

**Malline** is a simple and powerful template language for Swift. It provides a
syntax similar to Handlebars & Mustache. If you're familiar with these, you will
feel right at home with Malline.

## Example

```html+django
There are {{ articles.count }} articles.

<ul>
  {% for article in articles %}
    <li>{{ article.title }} by {{ article.author }}</li>
  {% endfor %}
</ul>
```

```swift
import Malline

struct Article {
  let title: String
  let author: String
}

let context = [
  "articles": [
    Article(title: "Limitations and Inevitable Demise of Blockchains", author: "Tauno Lehtinen"),
    Article(title: "Distributed Social Networks in Swift", author: "Tauno Lehtinen"),
  ]
]

let environment = Environment(loader: FileSystemLoader(paths: ["templates/"]))
let rendered = try environment.renderTemplate(name: context)

print(rendered)
```

## The User Guide

Resources for Malline template authors to write Malline templates:

- [Language overview](docs/templates.md)
- [Built-in template tags and filters](docs/builtins.md)

Resources to help you integrate Malline into a Swift project:

- [Installation](docs/installation.md)
- [Getting Started](docs/getting-started.md)
- [API Reference](docs/api.md)
- [Custom Template Tags and Filters](docs/custom-template-tags-and-filters.md)

## License

Malline is licensed under the MIT license. See [LICENSE](LICENSE) for more
info.
