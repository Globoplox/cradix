# A radix like tree specialized in uri path for routing purpose.
# Usage:
# ```
# radix = Cradix(String).new
# radix.add "/users", "List users"
# radix.add "/users/:id", "Get a user by id"
# radix.add "/users/self", "Get the current login in user"
# puts radix.search("/users/toto").first # => {"Get a user by id", {"id" => "toto"}}
# puts radix.search("/users/self").first # => {"Get the current login in user", {}}
# ```
class Cradix(Payload)
  VERSION = {{ `shards version #{__DIR__}`.chomp.stringify }}

  @payload : Payload?
  @children : Hash(String, Cradix(Payload))?
  @path_parameters : Hash(String, Cradix(Payload))?
  @wildcrad : Payload?
  
  # Add an entry to the tree.
  # *path* is expected to be an url path, with optional placeholders prefixed with ':'.
  # If their was already a payload for this path, it is redfined.
  def add(path : String, payload : Payload) : Nil
    add path.split('/', remove_empty: true), payload
  end

  # :nodoc:
  protected def add(words : Array(String), payload : Payload) : Nil
    if words.empty?
      @payload = payload
    else
      word = words.shift
      if word == "*"
        @wildcard = payload
      elsif word.starts_with? ':'
        map = @path_parameters ||= {} of String => Cradix(Payload)
        node = map[word.lstrip ':'] ||= Cradix(Payload).new
      else
        map = @children ||= {} of String => Cradix(Payload)
        node = map[word] ||= Cradix(Payload).new
      end
      node.add words, payload if node
    end
  end
  
  # Search the tree for matching elements.
  # Returns an array of payloads and extracted url parameters.
  # there might be multiple results when path parameters are involved. 
  # The non wildcard match always appear first in the results if there is one.
  # Example:
  # ```
  # node.add "/user/toto/name", "A"
  # node.add "/user/:id/name", "B"
  # node.add "/:blib/:blob/name", "C"
  # node.add "/:foo/:bar/age", "D"
  # node.search "/user/toto/name" # => [{"A", {}},
  #                                     {"B", {"id" => "toto"}},
  #                                     {"C", {"blib" => "user", "blob" => "toto"}}]
  # ```
  def search(path : String) : Array({Payload, Hash(String, String), String?})
    results = [] of {Payload, Hash(String, String), String?}
    search results, path.split '/', remove_empty: true
    results
  end


  # :nodoc:
  protected def search(results, path, parameters = {} of String => String, index = 0)
    if index >= path.size
      @payload.try do |payload|  
        results.push({payload, parameters, nil})
      end
    else
      word = path[index]
      @children.try &.[word]?.try &.search results, path, parameters, index + 1
      
      @path_parameters.try &.each do |(name, node)|
        node.search results, path, parameters.dup.tap(&.[name] = word), index + 1
      end

      @wildcard.try do |payload|
        results.push({payload, parameters, "/#{path[index..].join '/'}"})
      end
    end
  end
end