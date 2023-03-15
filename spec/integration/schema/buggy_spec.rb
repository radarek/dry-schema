# frozen_string_literal: true

RSpec.describe Dry::Schema, "unexpected keys" do
  subject(:schema) do
    Dry::Schema.define do
      config.validate_keys = true

      required(:name).filled(:string)
      required(:ids).filled(:array).each(:integer)

      required(:address).hash do
        required(:city).filled(:string)
        required(:zipcode).filled(:string)
      end

      required(:roles).array(:hash) do
        required(:name).filled(:string)
        required(:expires_at).value(:date)
      end
    end
  end

  context "with binary searching" do
    it "copies key map from the parent and includes new keys from child" do
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
  end

  context "with binary searching" do
    it "copies key map from the parent and includes new keys from child" do
      schema = Dry::Schema.Params do
        config.validate_keys = true

        required(:fooAA).filled(:string)
      end

      expect(schema.(fooA: "string").errors.to_h)
        .to eql({fooAA: ["is missing"], fooA: ["is not allowed"]})
    end
  end

  # it 'testing input paths' do
  #   schema = Dry::Schema.Params do
  #     config.validate_keys = true

  #     required(:foo)
  #     required(:bar).hash do
  #       required(:baz)
  #     end
  #     required(:qux).array(:hash) do
  #       required(:fred)
  #     end
  #     required(:vlad).array(:string)
  #     required(:bob).hash do
  #     end
  #   end

  #   input = { foo: 1, bar: { baz: 123, qux: { waldo: { fred: 1 }, thud: "a" } } }
  # end
end
