# Installation

## Swift Package Manager

If you're using the Swift Package Manager, you can add `Malline` to your
dependencies inside `Package.swift`.

```
    import PackageDescription

    let package = Package(
      name: "MyApplication",
      dependencies: [
        .Package(url: "https://github.com/Naamio/malline.git", majorVersion: 0, minor: 2),
      ]
    )
```
