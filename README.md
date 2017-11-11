# Malline

[![Build Status](https://travis-ci.org/omnijarstudio/malline.svg?branch=master)](https://travis-ci.org/omnijarstudio/malline)

Malline is a simple and powerful template language for Swift. It provides a
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
import Stencil

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

## Philosophy

Stencil follows the same philosophy of Django:

> If you have a background in programming, or if you’re used to languages which
> mix programming code directly into HTML, you’ll want to bear in mind that the
> Django template system is not simply Python embedded into HTML. This is by
> design: the template system is meant to express presentation, not program
> logic.

## The User Guide

Resources for Stencil template authors to write Stencil templates:

- [Language overview](docs/templates.md)
- [Built-in template tags and filters](docs/builtins.md)

Resources to help you integrate Stencil into a Swift project:

- [Installation](docs/installation.md)
- [Getting Started](docs/getting-started.md)
- [API Reference](docs/api.md)
- [Custom Template Tags and Filters](docs/custom-template-tags-and-filters.md)

## License

Malline is licensed under the MIT license. See [LICENSE](LICENSE) for more
info.
