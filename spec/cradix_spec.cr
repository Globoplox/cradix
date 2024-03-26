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
  
  it "Can get a simple route" do
    radix.search("/users").should eq [{"List users", {} of String => String}]
  end

  it "Can get a wildcard route" do
    radix.search("/users/toto").should eq [{"Get a user by id", {"id" => "toto"}}]
  end

  it "Can get several results with the non-wildcard being the first" do
    radix.search("/users/self").should eq [
      {"Get the current login in user", {} of String => String},
      {"Get a user by id", {"id" => "self"}}
    ]
  end

  it "Return no result in case of mismatch" do
    radix.search("/nowhere").size.should eq 0
  end

  it "Can return the root" do
    radix.search("/").should eq [{"Root", {} of String => String}]
  end

  it "Handles presence and absence of terminal /" do
    radix.search("/users/toto/friends").should eq [{"Get a user friends", {"user_id" => "toto"}}]
    radix.search("/users/toto/pets/").should eq [{"Get a user pets", {"user_id" => "toto"}}]
  end

  it "Handle presence and absence of starting /" do
    radix.search("").should eq [{"Root", {} of String => String}]
  end
  
  it "Handles duplicate /" do
    radix.add "/duplicate//test", "Duplicate test"
    radix.search("/duplicate//test").should eq [{"Duplicate test", {} of String => String}]
    radix.search("/duplicate/test").should eq [{"Duplicate test", {} of String => String}]
    radix.search("/duplicate/something/test").size.should eq 0
  end
  
end
