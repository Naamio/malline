# Getting Started

The easiest way to render a stencil using Stencil is to create a stencil and
call render on it providing a context.

```
    let stencil = Stencil(stencilString: "Hello {{ name }}")
    try stencil.render(["name": "tauno"])
```

For more advanced uses, you would normally create an `Environment` and call
the `renderStencil` convinience method.

```
    let environment = Environment()

    let context = ["name": "tauno"]
    try stencil.renderStencil(string: "Hello {{ name }}", context: context)
```

## Stencil Loaders

A stencil loader allows you to load files from disk or elsewhere. Using a
`FileSystemLoader` we can easily render a stencil from disk.

For example, to render a stencil called `index.html` inside the
`stencils/` directory we can use the following:

```
    let fsLoader = FileSystemLoader(paths: ["stencils/"])
    let environment = Environment(loader: fsLoader)

    let context = ["name": "tauno"]
    try stencil.renderStencil(name: "index.html", context: context)
```
