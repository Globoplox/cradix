require "./spec_helper"

describe Cradix do

  radix = Cradix(String).new
  radix.add "/users", "List users"
  radix.add "/users/:id", "Get a user by id"
  radix.add "/users/self", "Get the current login in user"
  radix.add "/users/:user_id/pets", "Get a user pets"
  radix.add "/users/:user_id/pet/:id", "Get a user pet by id"
  radix.add "/users/:user_id/friends/", "Get a user friends"
  radix.add "/users/:user_id/friend/:id/", "Get a user friend by id"
  radix.add "/", "Root"
  radix.add "/users/:id/files/*", "Get a user file by path"
  
  it "Can get a simple route" do
    radix.search("/users").should eq [{"List users", {} of String => String, nil}]
  end

  it "Can get a wildcard route" do
    radix.search("/users/toto").should eq [{"Get a user by id", {"id" => "toto"}, nil}]
  end

  it "Can get several results with the non-wildcard being the first" do
    radix.search("/users/self").should eq [
      {"Get the current login in user", {} of String => String, nil},
      {"Get a user by id", {"id" => "self"}, nil}
    ]
  end

  it "Return no result in case of mismatch" do
    radix.search("/nowhere").size.should eq 0
  end

  it "Can return the root" do
    radix.search("/").should eq [{"Root", {} of String => String, nil}]
  end

  it "Handles presence and absence of terminal /" do
    radix.search("/users/toto/friends").should eq [{"Get a user friends", {"user_id" => "toto"}, nil}]
    radix.search("/users/toto/pets/").should eq [{"Get a user pets", {"user_id" => "toto"}, nil}]
  end

  it "Handle presence and absence of starting /" do
    radix.search("").should eq [{"Root", {} of String => String, nil}]
  end

  it "Handles wildcard in path" do
    radix.search("/users/toto/files/root/pictures/holidays/2024/beach.raw").should eq [
      {"Get a user file by path", {"id" => "toto"} of String => String, "/root/pictures/holidays/2024/beach.raw"}
    ]
  end

  it "Handles duplicate /" do
    radix.add "/duplicate//test", "Duplicate test"
    radix.search("/duplicate//test").should eq [{"Duplicate test", {} of String => String, nil}]
    radix.search("/duplicate/test").should eq [{"Duplicate test", {} of String => String, nil}]
    radix.search("/duplicate/something/test").size.should eq 0
  end
  
end
