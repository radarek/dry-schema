# frozen_string_literal: true

RSpec.describe Dry::Schema, "OR messages" do
  context "with two predicates" do
    subject(:schema) do
      Dry::Schema.define do
        required(:foo) { str? | int? }
      end
    end

    it "returns success for valid input" do
      expect(schema.(foo: "bar")).to be_success
      expect(schema.(foo: 321)).to be_success
    end

    it "provides OR error message for invalid input where all both sides failed" do
      expect(schema.(foo: []).errors).to eql(foo: ["must be a string or must be an integer"])
    end
  end

  context "with a predicate and a conjunction of predicates" do
    subject(:schema) do
      Dry::Schema.define do
        required(:foo) { str? | (int? & gt?(18)) }
      end
    end

    it "returns success for valid input" do
      expect(schema.(foo: "bar")).to be_success
      expect(schema.(foo: 321)).to be_success
    end

    it "provides OR message for invalid input where both sides failed" do
      expect(schema.(foo: []).errors).to eql(foo: ["must be a string or must be an integer"])
    end

    it "provides error messages for invalid input where right side failed" do
      expect(schema.(foo: 17).errors).to eql(foo: ["must be a string or must be greater than 18"])
    end
  end

  context "with a predicate and an each operation" do
    subject(:schema) do
      Dry::Schema.define do
        required(:foo) { str? | value(:array?).each(:int?) }
      end
    end

    it "returns success for valid input" do
      expect(schema.(foo: "bar")).to be_success
      expect(schema.(foo: [1, 2, 3])).to be_success
    end

    it "provides OR message for invalid input where both sides failed" do
      expect(schema.(foo: {}).errors).to eql(foo: ["must be a string or must be an array"])
    end

    it "provides error messages for invalid input where right side failed" do
      expect(schema.(foo: %w[1 2 3]).errors).to eql(
        foo: {
          0 => ["must be an integer"],
          1 => ["must be an integer"],
          2 => ["must be an integer"]
        }
      )
    end
  end

  context "with a predicate and a schema" do
    subject(:schema) do
      Dry::Schema.define do
        required(:foo) { str? | hash { required(:bar).filled } }
      end
    end

    it "returns success for valid input" do
      expect(schema.(foo: "bar")).to be_success
      expect(schema.(foo: {bar: "baz"})).to be_success
    end

    it "provides OR message for invalid input where both sides failed" do
      expect(schema.(foo: []).errors).to eql(foo: ["must be a string or must be a hash"])
    end

    it "provides error messages for invalid input where right side rules failed" do
      expect(schema.(foo: {bar: ""}).errors).to eql(foo: {bar: ["must be filled"]})
    end
  end

  context "with two schemas" do
    name_schema = Dry::Schema.define do
      required(:name).filled(:string)
    end

    nickname_schema = Dry::Schema.define do
      required(:nickname).filled(:string)
    end

    subject(:schema) do
      Dry::Schema.define do
        required(:user) { name_schema | nickname_schema }
      end
    end

    it "returns success for valid input" do
      expect(schema.(user: {name: "John"})).to be_success
      expect(schema.(user: {nickname: "John"})).to be_success
    end

    it "provides error messages for invalid input where both sides failed" do
      expect(schema.(user: {}).errors.to_h).to eql(user: {or: [{name: ["is missing"]}, {nickname: ["is missing"]}]})
    end
  end

  context "with three schemas" do
    name_schema = Dry::Schema.define do
      required(:name).filled(:string)
    end

    nickname_schema = Dry::Schema.define do
      required(:nickname).filled(:string)
    end

    alias_schema = Dry::Schema.define do
      required(:alias).filled(:string)
    end

    subject(:schema) do
      Dry::Schema.define do
        required(:user) { name_schema | nickname_schema | alias_schema }
      end
    end

    it "returns success for valid input" do
      expect(schema.(user: {name: "John"})).to be_success
      expect(schema.(user: {nickname: "John"})).to be_success
      expect(schema.(user: {alias: "Slick"})).to be_success
    end

    it "provides error messages for invalid input where all sides failed" do
      expect(schema.(user: {}).errors.to_h).to eql(
        {
          user: {or: [{name: ["is missing"]},
                      {nickname: ["is missing"]},
                      {alias: ["is missing"]}]}
        }
      )
    end
  end

  context "with four schemas" do
    name_schema = Dry::Schema.define do
      required(:name).filled(:string)
    end

    nickname_schema = Dry::Schema.define do
      required(:nickname).filled(:string)
    end

    alias_schema = Dry::Schema.define do
      required(:alias).filled(:string)
    end

    favorite_food_schema = Dry::Schema.define do
      required(:favorite_food).filled(:string)
    end

    subject(:schema) do
      Dry::Schema.define do
        required(:user) { name_schema | nickname_schema | alias_schema | favorite_food_schema }
      end
    end

    it "returns success for valid input" do
      expect(schema.(user: {name: "John"})).to be_success
      expect(schema.(user: {nickname: "John"})).to be_success
      expect(schema.(user: {alias: "Slick"})).to be_success
      expect(schema.(user: {favorite_food: "pizza"})).to be_success
    end

    it "provides error messages for invalid input where all sides failed" do
      expect(schema.(user: {}).errors.to_h).to eql(
        {
          user: {or: [{name: ["is missing"]},
                      {nickname: ["is missing"]},
                      {alias: ["is missing"]},
                      {favorite_food: ["is missing"]}]}
        }
      )
    end
  end
end
