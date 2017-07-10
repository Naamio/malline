# Custom Stencil Tags and Filters

You can build your own custom filters and tags and pass them down while
rendering your stencil. Any custom filters or tags must be registered with a
extension which contains all filters and tags available to the stencil.

```
    let ext = Extension()
    // Register your filters and tags with the extension

    let environment = Environment(extensions: [ext])
    try environment.renderStencil(name: "example.html")
```

## Custom Filters

Registering custom filters:

```
    ext.registerFilter("double") { (value: Any?) in
      if let value = value as? Int {
        return value * 2
      }

      return value
    }
```

Registering custom filters with arguments:

```
    ext.registerFilter("multiply") { (value: Any?, arguments: [Any?]) in
      let amount: Int

      if let value = arguments.first as? Int {
        amount = value
      } else {
        throw StencilSyntaxError("multiple tag must be called with an integer argument")
      }

      if let value = value as? Int {
        return value * 2
      }

      return value
    }
```

## Custom Tags

You can build a custom stencil tag. There are a couple of APIs to allow you to
write your own custom tags. The following is the simplest form:

```
    ext.registerSimpleTag("custom") { context in
      return "Hello World"
    }
```

When your tag is used via `{% custom %}` it will execute the registered block
of code allowing you to modify or retrieve a value from the context. Then
return either a string rendered in your stencil, or throw an error.

If you want to accept arguments or to capture different tokens between two sets
of stencil tags. You will need to call the `registerTag` API which accepts a
closure to handle the parsing. You can find examples of the `now`, `if` and
`for` tags found inside Stencil source code.
