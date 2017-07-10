# Malline API

This document describes Malline API for use in applications and libraries,
and not the stenciling language.

## Environment

An environment contains shared configuration such as custom filters and tags
along with stencil loaders.

```
let environment = Environment()
```

You can optionally provide a loader or extensions when creating an environment:

```
let environment = Environment(loader: ..., extensions: [...])
```

### Rendering a Stencil

Environment provides convinience methods to render a stencil either from a
string or a stencil loader.

```
// Render a textual stencil with a given context.
let stencil = "Hello {{ name }}"
let context = ["name": "Kyle"]
let rendered = environment.renderStencil(string: stencil, context: context)
```

Rendering a stencil from the configured loader:

```
// Render a file-based stencil with a given context.
let context = ["name": "Kyle"]
let rendered = environment.renderStencil(name: "example.html", context: context)
```

### Loading a Stencil

Environment provides an API to load a stencil from the configured loader.

```
// Load a stencil with a given name.
let stencil = try environment.loadStencil(name: "example.html")
```

## Loader

Loaders are responsible for loading stencils from a resource such as the file
system.

Stencil provides a ```FileSytemLoader``` which allows you to load a stencil
directly from the file system.

### FileSystemLoader

Loads stencils from the file system. This loader can find stencils in folders
on the file system.

```
// Loads stencils from the local file system.
FileSystemLoader(paths: ["./stencils"])
```

```
// Loads stencils from a bundle on the local file system.
FileSystemLoader(bundle: [Bundle.main])
```

### Custom Loaders

`Loader` is a protocol, so you can implement your own compatible loaders. You
will need to implement a `loadStencil` method to load the stencil,
throwing a `StencilDoesNotExist` when the stencil is not found.

```
class ExampleMemoryLoader: Loader {
    func loadStencil(name: String, environment: Environment) throws -> Stencil {
        if name == "index.html" {
            return Stencil(stencilString: "Hello", environment: environment)
        }

    throw StencilDoesNotExist(name: name, loader: self)
    }
}
```

## Context

A `Context` is a structure containing any stencils you would like to use in
a stencil. It’s somewhat like a dictionary, however you can push and pop to
scope variables. So that means that when iterating over a for loop, you can
push a new scope into the context to store any variables local to the scope.

You would normally only access the `Context` within a custom stencil tag or
filter.

### Subscripting

You can use subscripting to get and set values from the context.

```
// Sets and retrieves a value to / from the context.
context["key"] = value
let value = context["key"]
```

###  `push()`

A `Context` is a stack. You can push a new level onto the `Context` so that
modifications can easily be poped off. This is useful for isolating mutations
into scope of a stencil tag. Such as `{% if %}` and `{% for %}` tags.

```
// Pushes a `name` property to the context.
context.push(["name": "example"]) {
    // context contains name which is `example`.
}
```

    // name is popped off the context after the duration of the closure.

###  `flatten()`

Using `flatten()` method you can get whole `Context` stack as one
dictionary including all variables.

```
let dictionary = context.flatten()
```
