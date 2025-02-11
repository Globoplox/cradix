# Cradix

A simple radix like tree specialized in URL path routing with supports for path parameters and wildcards, in crystal lang.

## Installation

1. Add the dependency to your `shard.yml`:

   ```yaml
   dependencies:
     cradix:
       github: globoplox/cradix
   ```

2. Run `shards install`

## Usage

```crystal
require "cradix"

radix = Cradix(String).new
radix.add "/users", "List users"
radix.add "/users/:id", "Get a user by id"
radix.add "/users/:id/file/*", "Get a user file by path"
radix.add "/users/self", "Get the current login in user"
puts radix.search("/users/toto").first # => {"Get a user by id", {"id" => "toto"}, nil}
puts radix.search("/users/self").first # => {"Get the current login in user", {}, nil}
puts radix.search("/users/toto/file/holiday/beach.raw").first # => {"Get a user file by path", {"id" => "toto"}, "/holiday/beach.raw"} 
```

## Changelog

## [1.1.0] - 2025-02-11
### Added
- Support for wildcard (in addition to existing support of path parameters)
