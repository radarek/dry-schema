require 'dry/schema'
require 'benchmark'

def sized_benchmark(size, reporter)
  hash = size.times.to_h { [:"key_#{_1}", true] }
  nested = { foo: { bar: { baz: hash } } }

  schema = Dry::Schema.define do
    config.validate_keys = true

    required(:foo).hash do
      required(:bar).hash do
        required(:baz).hash do
          hash.each do |key, _|
            required(key)
          end
        end
      end
    end
  end

  reporter.report("schema call with size = #{size}") do
    schema.call(nested)
  end
end

Benchmark.bmbm do |x|
  sized_benchmark(1, x)
  sized_benchmark(10, x)
  sized_benchmark(100, x)
  sized_benchmark(1000, x)
  sized_benchmark(10000, x)
end
