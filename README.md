# PackageWebHelp.jl

Most third-party Julia packages have a documentation site, or at least a repository README, that makes understanding and using the package much easier. This package makes it easy to open the documentation of a particular package from the REPL in the default system browser, simply by typing, e.g.,

```julia
package_help("Plots")
```

or even simply

```julia
help("MLJ")
```

## Installation

At the Julia REPL prompt, enter

```julia
import(Pkg); Pkg.add("https://github.com/tobydriscoll/PackageWebHelp.jl")
```

## Usage

In a Julia session, enter `using PackageWebHelp`. This creates the function `package_help`, which is aliased to just `help`. Here is the documentation string.

```
    help(module_name)
    help(module_name;timeout=nsec)

Attempt to open the default web browser to documentation for the package `module_name`, which is either a Symbol or a String. If the package is a dependency of the active project, the documentation for the active version is shown if known; otherwise, the function looks for the latest/stable version. If no documentation location is known, the repository page from the registry is opened.

If the `timeout=` argument is given, it defines the timeout in seconds used before giving up on a particular URL.
```
