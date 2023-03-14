# frozen_string_literal: true

RSpec.describe Dry::Schema, "bug" do
  it "works properly" do
    schema = Dry::Schema.Params do
      config.validate_keys = true

      required(:a).filled(:string)
      required(:fooA).filled(:string)
      required(:foo).array(:hash) do
        required(:bar).filled(:string)
      end
    end

    expect(schema.(a: "string", fooA: "string", foo: "string").errors.to_h)
      .to eql({foo: ["must be an array"]})
  end

  # it "works properly" do
  #   schema = Dry::Schema.Params do
  #     config.validate_keys = true

  #     required(:a).filled(:string)
  #     required(:fooA).filled(:string)
  #     required(:foo).hash do
  #       required(:bar).filled(:string)
  #       required(:baz).filled(:string)
  #     end
  #   end

  #   expect(schema.(a: "string", fooA: "string", foo: "string", bar: [a:1], baz: { qux: 1}).errors.to_h)
  #     .to eql({foo: ["must be an array"]})
  # end
end
