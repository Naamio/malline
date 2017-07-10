# The Malline stencil language

Stencil is a simple and powerful stencil language for Swift. It provides a
syntax similar to Django and Mustache. If you're familiar with these, you will
feel right at home with Stencil.

```
    There are {{ articles.count }} articles.

    <ul>
      {% for article in articles %}
        <li>{{ article.title }} by {{ article.author }}</li>
      {% endfor %}
    </ul>
```

```
    import Stencil

    struct Article {
      let title: String
      let author: String
    }

    let context = [
      "articles": [
        Article(title: "Migrating from OCUnit to XCTest", author: "Kyle Fuller"),
        Article(title: "Memory Management with ARC", author: "Kyle Fuller"),
      ]
    ]

    let environment = Environment(loader: FileSystemLoader(paths: ["stencils/"])
    let rendered = try environment.renderStencil(name: context)

    print(rendered)
```

## The User Guide

### For Stencil Writers

Resources for Stencil stencil authors to write Stencil stencils.

 - [Stencils](./templates.md)
 - [Build-ins](./builtins.md)

### For Developers

Resources to help you integrate Stencil into a Swift project.

- [Installation](./installation.md)
- [Getting Started](./getting-started.md)
- [API](./api.md)
- [Custom Stencil Tags and Filters](./custom-stencil-tags-and-filters.md)
