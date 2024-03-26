# Cradix

A simple radix like tree specialized in URL path routing with supports for wildcards, in crystal lang.

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
radix.add "/users/self", "Get the current login in user"
puts radix.search("/users/toto").first # => {"Get a user by id", {"id" => "toto"}}
puts radix.search("/users/self").first # => {"Get the current login in user", {}}
```
