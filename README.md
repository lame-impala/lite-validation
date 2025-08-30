# Lite::Validation
A validation framework that works with hashes, arrays as well
as arbitrary objects. Traverse nested data structures, apply validation rules,
transform input into new shape through an immutable, composable interface
that treats validation as a general-purpose computational tool.

- Extensible wrapper system supports custom collections (like `ActiveRecord::Relation`)
- Pluggable predicate engines — ships with `Dry::Logic` adapter for declarative validation
- Configurable result types and error formats
- Transform data while validating through integrated commit/transformation mechanics

Engineered for consistent performance regardless of validation outcome.
This makes it ideal for high-throughput scenarios where validation serves
as filtering, decision-making, or data processing logic — not just input sanitization.
Whether validating inputs that mostly pass or mostly fail, performance remains predictable.
Perfect for applications that need validation throughout the system:
API endpoints, background jobs, data pipelines, and anywhere you need reliable
validation with transformation capabilities.

## Getting started
Before validating data, you'll need to create a **coordinator** —
a configuration object that defines how the validator integrates
with your application. The coordinator specifies what types
to use for results, options, and errors, making the library adaptable
to different Ruby ecosystems. Here's a basic setup with reasonable defaults,
the same setup we’ll use throughout the examples in this documentation:

```ruby rspec coordinator_dry_hierarchical
Hierarchical = Coordinator::Builder.define do
  interface_adapter Adapters::Interfaces::Dry
  validation_error_adapter do
    structured_error do |code, message: nil, data: nil|
      StructuredError::Record.instance(code, message: message, data: data)
    end
    internal_error do |id, message: nil, data: nil|
      message ||= case id
                  when :value_missing then 'Value is missing'
                  when :not_iterable then 'Value is not iterable'
                  end

      structured_error(id, message: message, data: data)
    end
  end
  final_error_adapter Coordinator::Errors::Hierarchical
end
```

This coordinator:
- Uses `Dry::Monads::Result` for success/failure results and also as a stand-in
  for option type when optional value is yielded to a validation block
- Stores validation errors into the built-in `StructuredError::Record` class
- Translates internal framework errors into readable messages
- Organizes final errors in a hierarchical structure

We'll cover advanced configuration options [later](#configuration).
For now, this setup gives you everything needed to start validating.

## Validation
With a coordinator configured, you can create validators.
Each validator is initialized with the data, coordinator,
and an optional context object for sharing state across validations.

The validator follows an immutable, fluent design. Each validation method
(`validate`, `at`, `each_at`, `satisfy`) returns either the original validator
(if unchanged) or a new validator with updated state. Chain your validations
together, then call `to_result` to get the final outcome.

Here's basic scalar validation:

```ruby rspec validation_scalar
result = Lite::Validation::Validator
  .instance(101, coordinator, context: { limit: 100 })
  .validate { |value| Refute(:not_an_integer) unless value.is_a?(Integer) }
  .validate { |value, context| Dispute(:excessive) if value > context[:limit] }
  .to_result

expect(result.failure).to match({ errors: [have_attributes(code: :excessive)] })
```

The core of validation is the `validate` method and its counterpart `validate?`.
These methods expose the current value and context to your validation block,
expecting a ruling in return — a decision about the value's validity.
There are four types of ruling available in validate blocks:
- `Pass()` — Indicates the value is valid. Rarely used since returning
  `nil` has the same effect.
- `Dispute(code, message: nil, data: nil)` — Marks the value as invalid but allows validation
  to continue on this node. All ancestor nodes also become disputed. You can also pass
  a structured error object: `Dispute(structured_error)`
- `Refute(code, message: nil, data: nil)` — Marks the value as invalid with a fatal error
  that stops further validation on this node. Parent nodes become disputed unless this
  occurs in a [critical section](#critical-section). Also accepts structured errors: `Refute(structured_error)`.
- `Commit(value)` — Transforms the input data into a new structure. This enables validation
  with simultaneous data transformation — we'll cover this [later](#transforming-the-validated-object).
  Commited node can't be reopened for validation again, such attempt will trigger runtime error.

The distinction between `Dispute` and `Refute` gives you some control over validation flow:
use `Dispute` for errors where you want validation to continue, and `Refute` for errors serious
enough to halt processing.

### Validating structured data
The library's capabilities become more apparent with hierarchical data.
Pass a path as the first argument to `validate` — validator
will navigate to that value and yield it to the validation block:

```ruby rspec validation_hash_aligned
result = Validator
  .instance({ foo: -1 }, coordinator)
  .validate(:foo) { |foo, _ctx| Dispute(:negative) if foo < 0 }
  .to_result

expect(result.failure).to match({ children: { foo: { errors: [have_attributes(code: :negative)] } } })
```

**Separating data location from error location:**
Use the `from` parameter to validate data from one path but store errors at a different location:

```ruby rspec validation_hash_unaligned
result = Validator
  .instance({ foo: -1 }, coordinator)
  .validate(:bar, from: [:foo]) { |bar, _ctx| Dispute(:negative) if bar < 0 }
  .to_result

expect(result.failure).to match({ children: { bar: { errors: [have_attributes(code: :negative)] } } })
```

This separation enables two powerful patterns:

**1. Meaningful error keys** — Store errors under descriptive names rather than raw data keys:

```ruby rspec validation_hash_tuple_unaligned
result = Validator
  .instance({ subtotal: 80, charges: 21 }, coordinator, context: { limit: 100 })
  .validate(:total, from: [[:subtotal, :charges]]) do |(subtotal, charges), context|
    Dispute(:excessive) if subtotal + charges > context[:limit]
  end.to_result

expect(result.failure).to match({ children: { total: { errors: [have_attributes(code: :excessive)] } } })
```

Note how the `from` parameter accepts an array of paths — this creates a tuple from multiple values,
perfect for cross-field validations.

**2. Data transformation** — Remap input data into new structures using `Commit` rulings.
The `from` parameter lets you source data from one location while building transformed
output at another. We'll explore this pattern
in detail [later](#transforming-the-validated-object).

### Alternative syntax
You can also apply rulings directly to validator nodes rather
of returning them from validation blocks. This permits
more concise phrasing in certain cases — for example when passing validator
into functions:

```ruby rspec node_disputed
def self.validate_total(validator)
  validator.dispute(:excessive, at: [:total]) if validator.value > validator.context[:max]
end

validator = Validator.instance(201, coordinator, context: { max: 200 })
disputed = validate_total(validator)

expect(disputed.to_result.failure)
  .to match({ children: { total: { errors: [have_attributes(code: :excessive)] } } })
```

Remember that validators are immutable — methods like `dispute`, `refute`, and `commit`
return new validator instance with updated state.

### Handling missing values
The `validate?` method provides flexible handling of missing values.
While `validate` immediately refutes nodes when values aren't found,
`validate?` offers more nuanced options:

**Default behavior:** Skip validation entirely if the value is missing — the validator state
remains unchanged.

**With missing value strategies:** Call `validate?` without a block, then chain `.some_or_nil` or `.option`
to control how missing values are handled:

- **`some_or_nil`** — Passes `nil` for missing values. In tuples, only missing fields become `nil`,
  not the entire tuple.
- **`option`** — Passes an option type (like `Dry::Result::Failure(Unit)` when using the Dry interface).
  Again, in tuples only missing fields become *none* values.

The `option` strategy enables validations where fields have disjunctive relationships —
like "either `:foo` or `:bar` must be set, but not both":

```ruby rspec validation_option
result = Validator
  .instance({ foo: 'FOO', bar: 'BAR' }, coordinator)
  .validate?([:foo, :bar]).option { |(foo, bar), _ctx| Dispute(:xor_violation) unless foo.failure? ^ bar.failure? }
  .to_result

expect(result.failure)
  .to match({ children: { [:foo, :bar] => { errors: [have_attributes(code: :xor_violation)] } } })
```

### Validating objects
Beyond hashes and arrays, the validator works seamlessly with any Ruby object.
When navigating to a path, it calls the corresponding reader method on the object:

```ruby rspec validation_object
result = Validator
  .instance(OpenStruct.new(foo: 5), coordinator)
  .validate(:foo) { |foo| Dispute(:not_three) if foo != 3 }
  .to_result

expect(result.failure)
  .to match({ children: { foo: { errors: [have_attributes(code: :not_three)] } } })
```

**Graceful error handling:** If the object doesn't respond to a reader method or raises an exception,
the validator automatically converts this into a validation error:

```ruby rspec validation_object_reader_unimplemented
result = Validator
  .instance(Object.new, coordinator)
  .validate(:foo) { |foo| Dispute(:not_three) if foo != 3 }
  .to_result

expect(result.failure)
  .to match({ children: { foo: { errors: [have_attributes(code: :invalid_access)] } } })
```

This means you can validate any object without worrying about method availability — missing methods
become validation errors rather than runtime exceptions.

## Predicates
Common validation logic can be extracted into reusable **predicates** that you invoke
by name using the `satisfy` method. This promotes consistency and reduces duplication
across your validation code.

Define predicates using a builder pattern:

```ruby rspec predication_define_native
Predicate.define(:presence) do
  validate_value do |value, _context|
    next Ruling::Invalidate(:blank, message: 'must not be nil') if value.nil?

    Ruling::Invalidate(:blank, message: 'must not be empty') if value.respond_to?(:empty?) && value.empty?
  end

  validate_option do |option, _context|
    next Ruling::Invalidate(:blank, message: 'must be given') if option.failure?

    validate_value(option.success)
  end
end
```

**Key concepts:**
- **`Ruling::Invalidate`** — A suspended ruling that doesn't specify severity (`dispute` vs `refute`).
  The caller determines severity when using the predicate via `satisfy`.
- **`validate_value`** — Handles definite values (the common case)
- **`validate_option`** — Handles optional values from `satisfy?` with the option strategy.
This is not required — omit if your predicate doesn't need to handle missing values.

This separation lets predicates work with both definite and optional values
while leaving severity decisions to the validation context where they're used.

### Declarative predicates
You can integrate existing predicate libraries through adapters.
The library ships with a `Dry::Logic` adapter that lets you define
predicates using Dry's declarative syntax.

**Setup:** Require the adapter and configure error handling:

```ruby rspec predication_foreign_configuration
require 'lite/validation/validator/adapters/predicates/dry'

error_adapter = proc { |rule, value| StructuredError::Record.instance(:"failed: #{rule}", data: value) }

Predicate::Registry.register_adapter :dry, Adapters::Predicates::Dry::Engine.instance(error_adapter)
```

The error adapter proc converts `Dry::Logic` failures into structured errors.
It receives the failed rule and the value that caused the failure.

**Define predicates:** With the adapter registered, you can create named predicates using
`Dry::Logic` syntax:
```ruby rspec predication_define_foreign
positive_number = Predicate::Registry.engine(:dry).build([:val]) { number? & gt?(0) }
Predicate::Registry.register_predicate :positive_number, positive_number
```

### Using predicates with `satisfy`
The `satisfy` method invokes predefined predicates on validator nodes.
For named predicates (whether native or adapter-based), simply return the predicate
name from the block:

```ruby rspec predication_satisfy_declared
result = Validator
  .instance({ foo: -1 }, coordinator)
  .satisfy(:foo, severity: :refute) { :presence }
  .satisfy(:foo, severity: :dispute) { :positive_number }
  .to_result

expect(result.failure)
  .to match({ children: { foo: { errors: [have_attributes(code: :'failed: number? AND gt?(0)')] } } })
```

**Context-dependent predicates:** For predicates that need context data, use the builder pattern:

```ruby rspec predication_satisfy_contextual
result = Validator
  .instance({ foo: 101 }, coordinator, context: { max: 100 })
  .satisfy(:foo, using: :dry, severity: :dispute) do |builder, context|
    builder.call { lteq?(context[:max]) }
  end.to_result

expect(result.failure)
  .to match(children: { foo: { errors: [have_attributes(code: :'failed: lteq?(100)')]}})
```

**Severity control:** The `severity` parameter determines whether predicate failures become
disputes or refutations, giving you control over validation flow.

**Missing values:** Like `validate?`, the `satisfy?` method handles missing values
gracefully — skipping validation by default, or using `some_or_nil`/`option` strategies
when chained.

## Navigation
Navigate through data structures using `at` and `each_at` methods.
These methods look up values and create new validator nodes for deeper validation.

Like other validation methods, navigation supports the `from` parameter
to separate data location from validation location.

### Validating nested structures
Use `at` to navigate complex nested values and validate their internal structure.
If a node requires substantial processing, consider extracting the logic into
a separate function for clarity and reuse:

```ruby rspec navigation_nested_node
def self.foo(foo)
  foo.validate(:bar) { |bar, _ctx| Dispute(:excessive) if bar > 10 }
end

result = Validator
  .instance({ foo: { bar: 11 } }, coordinator).at(:foo) { |foo| foo(foo) }
  .to_result

expect(result.failure)
  .to match({ children: { foo: { children: { bar: { errors: [have_attributes(code: :excessive)] } } } } })
```

The `at` method passes a new validator node (positioned at the nested location)
to your block. This lets you apply the full range of validation tools
to nested data structures.

**Performance consideration:** Creating new validator nodes has overhead.
Use `at` when you need to validate multiple aspects of a nested structure,
but consider direct path validation (`validate(:foo, :bar)`) for simple cases.

### Validating collections
For arrays of complex objects, use `each_at` to validate each element:

```ruby rspec navigation_nested_node_each
result = Validator
  .instance({ foos: [{ bar: 10 }, { bar: 11 }] }, coordinator)
  .each_at(:foos) { |foo| foo.validate(:bar) { |bar, _ctx| Dispute(:excessive) if bar > 10 } }
  .to_result

expected_errors = { 
  children: { 
    foos: { 
      children: {
        1 => { 
          children: {
            bar: { errors: [have_attributes(code: :excessive)] }
          }
        }
      }
    }
  }
}

expect(result.failure).to match(expected_errors)
```

The `each_at` method creates a new validator node for each collection element,
enabling full validation of nested structures. Note how errors are indexed
by position (the second element gets index `1`).

**Performance optimization for scalars:**
When validating arrays of simple values, avoid the node creation overhead by chaining `validate`
directly after `each_at`:

```ruby rspec navigation_nested_node_each_validate
result = Validator.instance({ foos: [10, 11] }, coordinator)
  .each_at(:foos)
  .validate { |foo, _ctx| Dispute(:excessive) if foo > 10 }
  .to_result

expected_errors = {
  children: {
    foos: {
      children: {
        1 => {
          errors: [have_attributes(code: :excessive)]
        }
      }
    }
  }
}

expect(result.failure).to match(expected_errors)
```

This pattern skips node creation and validates each scalar value directly, significantly
improving performance for large collections of simple values.

**Using predicates with collections:**
You can also chain `satisfy` after `each_at` for declarative validation:
```ruby rspec navigation_nested_node_each_satisfy
result = Validator
  .instance({ foos: [10, 11] }, coordinator, context: { max: 10 })
  .each_at(:foos).satisfy(using: :dry, severity: :dispute) do |builder, context|
    builder.call { lteq?(context[:max]) }
  end.to_result

expected_errors = {
  children: {
    foos: {
      children: {
        1 => {
          errors: [have_attributes(code: :'failed: lteq?(10)')]
        }
      }
    }
  }
}

expect(result.failure).to match(expected_errors)
```

**Important limitation:** Context-dependent predicates with `satisfy` are built only once before
iteration begins. If your predication logic is based on per-element context, use `validate` instead.

**Missing value handling:** Like other validation methods, `at` and `each_at` have `?`
variants (`at?`, `each_at?`) that handle missing values gracefully. Note that
`some_or_nil` and `option` strategies don't apply to `each_at?` since they don't
make sense for collection elements.

**Supported collections:** Currently `each_at` works with `Array` and `Hash`. You can add support
for other collection types (like `Set` or `ActiveRecord::Relation`) using [custom wrappers](#custom-wrappers).

## Flow control
Basic flow control comes from the `Dispute`/`Refute` distinction—`Refute` rulings skip
all subsequent validations on that node.

For more sophisticated control, use `with_valid` to conditionally execute validation
logic based on node state.

### Conditional validation
Execute validation only when the current node is valid (neither disputed nor refuted):

```ruby rspec scoping_with_valid_node
expect do |yield_probe|
  Validator.instance({ foo: 'FOO', bar: 'BAR' }, coordinator).with_valid do |valid|
    yield_probe.to_proc.call
    valid
  end
end.to yield_control
```

### Multi-clause conditions
Validate nodes together only when all dependencies are valid:

```ruby rspec scoping_with_valid_children
expect do |yield_probe|
  Validator.instance({ foo: 'FOO', bar: 'BAR' }, coordinator)
    .dispute(:invalid, at: [:foo])
    .with_valid(:foo).and(:bar, &yield_probe)
end.not_to yield_control
```

This example validates `foo` and `bar` as a tuple, but only if both nodes are individually valid.
Since `foo` is disputed, the validation block never executes.

The `with_valid` method enables complex validation dependencies while maintaining clean,
readable validation logic.

## Critical section
Sometimes child node failures are so significant they should fail
the entire parent validation. The `critical` block propagates any `Refute`
ruling from within the block up to the parent node.

The `critical` method requires an error transformer lambda to adapt
child errors for the parent context. Without transformation, propagated
errors often don't make sense at the parent level.

### Error propagation
Here's a critical section with minimal transformation (just passing the error through):

```ruby rspec scoping_critical_refute_nested
result = Validator.instance({ user: { age: 'eleven' } }, coordinator).at(:user) do |user|
  user.critical(->(error, _path) { error }) do |critical|
    critical.validate(:age) do |age|
      Refute(:not_integer) unless age.is_a?(Integer)
    end
  end
end.to_result

expect(result.failure)
  .to match({ children: { user: { errors: [have_attributes(code: :not_integer)] } } })
```

The error "user is not_integer" is confusing because the problem is actually with the age field.

Use the transformer to create meaningful parent-level error messages:

```ruby rspec scoping_critical_rewrap_error
REWRAP_CRITICAL = lambda { |error, path|
  StructuredError::Record.instance(
    :invalid,
    message: "#{error.code} at #{path.join('.')}",
    data: { original_error: error, path: path }
  )
}

result = Validator.instance({ user: { age: 'eleven' } }, coordinator).at(:user) do |user|
  user.critical(REWRAP_CRITICAL) do |critical|
    critical.validate(:age) do |age|
      Refute(:not_integer) unless age.is_a?(Integer)
    end
  end
end.to_result

expect(result.failure)
  .to match({ children: { user: { errors: [have_attributes(code: :invalid, message: 'not_integer at age')] } } })
```

The transformer receives the original error and the path from the critical section start
to the failure point, enabling contextual error messages that make sense at the parent level.

## Transforming the validated object
The `Commit` ruling enables validation with simultaneous data transformation,
letting you reshape data while validating it.

### Ways to commit values
You can commit values through several mechanisms:
- Return `Commit(value)` from a `validate` block
- Call the `commit(value)` method on a validator node
- Pass `commit: true` to the `validate` or `satisfy` method (commits the original value if validation passes)
- Pass `commit: <collection_type>` to the `each_at` - gathers values of all committed nodes
into the specified collection — either `array` or `hash` and commits them to the node 
after the iteration.

Individual value commits aren't enough — you must also commit the containing structure. 
The validator can't automatically determine the desired output format, 
so you need to explicitly commit each level.

Use `auto_commit(as: :hash)` to gather committed child values into a new container:

```ruby rspec ruling_commit_complex
def self.item(item)
  item
    .satisfy(:name, commit: true) { :presence }
    .satisfy(:unit_price, from: [:price], commit: true ) { :presence }
    .auto_commit(as: :hash)
end

original_data = { 
  customer: { name: 'John Doe' }, 
  items: [{ price: 100, name: 'Item 1' }], 
  price: 100 
}

result = Validator
  .instance(original_data, coordinator)
  .satisfy(:customer_name, from: [:customer, :name], commit: true) { :presence }
  .validate(:total, from: [:price]) { |price, _ctx| price <= 100 ? Commit(price) : Refute(:excessive) }
  .each_at(:line_items, from: [:items], commit: :array) { |item| item(item) }
  .auto_commit(as: :hash)
  .to_result

transformed_data = { 
  customer_name: 'John Doe', 
  line_items: [{ name: 'Item 1', unit_price: 100 }], 
  total: 100 
}

expect(result.success).to eq(transformed_data)
```

This example demonstrates the full transformation pipeline:
1. Extract and validate data from nested sources (`customer.name`)
2. Commit individual values under new keys (`customer_name`, `total`, `line_items`, `unit_price`)
3. Build the final transformed structure with `auto_commit`

The result is a validated and transformed structure entirely different
from the original data.

## Implementing custom wrappers
The validator supports `Hash` and `Array` out of the box, 
but you can extend it to work with specialized collection types 
like `ActiveRecord::Relation`.

### Registering compatible classes
If your class implements the same interface as an existing wrapper 
but doesn't inherit from the expected base class, register it with an existing wrapper:

```ruby rspec implement_custom_wrapper
class NotArray
  extend Forwardable

  def initialize(array)
    @array = array
  end

  def_delegator :array, :length
  def_delegator :array, :[]
  def_delegator :array, :lazy

  private

  attr_reader :array
end

Complex::Registry.register(NotArray, Complex::Wrappers::Array)
```

This tells the validator to treat `NotArray` instances like arrays for navigation and iteration.

### Creating new wrappers
For containers that don't match existing patterns, create a custom wrapper by inheriting from:
- **`Wrappers::Abstract::NonIterable`** - For containers that support key-based access but not iteration
- **`Wrappers::Abstract::Iterable`** - For containers that support both access and iteration (enabling `each_at`)

**Required methods:**

For any wrapper:
- `fetch(key)` - returns `Option.some(value)` if the key exists, `Option.none` otherwise

For iterable wrappers, also implement:
- `reduce(initial_state, &block)` - yields `(accumulator, [value, key])` for each element

The abstract base classes handle all other functionality.
Register your custom wrapper the same way as shown above.

This extension system lets the validator work with any collection type
while maintaining consistent navigation and validation APIs.

## Configuration
The library's extensive configurability enables smooth integration
with existing systems, but requires upfront setup to become operational.
Two core areas need configuration:

1. **Error handling** - How validation errors are created, structured,
   and presented to your application
2. **Interface types** - What result and option types the library uses
   to communicate with your code

This flexibility lets you adapt the library to work with your existing error
handling patterns and result types, whether you're using a proprietary solution,
`Dry::Monads`, or some more exotic library.

### Validation errors
Validation errors must include the `StructuredError` marker module. This module
defines abstract methods as suggestions rather than requirements — the library
works with any type that includes the module.

For simple cases, use the built-in `StructuredError::Record` class, which accepts:
- `code` (required `Symbol`) - The error identifier
- `message` (optional `String`) - Human-readable description
- `data` (optional, any type) - Additional error context

### Error factory methods
The configuration needs to provide factories to create structured errors
from these three parameters:

**`structured_error(code, message: nil, data: nil)`**
Creates validation errors when your code explicitly disputes or refutes nodes.

**`internal_error(id, message: nil, data: nil)`**
Translates internal framework errors into structured errors. Current internal error codes:

- `:execution_error` - Exception caught when calling foreign code
- `:invalid_access` - Object accessor method raised an exception
- `:not_iterable` - Attempted iteration on unsupported collection type
- `:value_missing` - Requested value not found in data structure

If you don't need to transform internal errors into something more meaningful
in your system, this method can simply delegate to `structured_error`.

### Error building strategies
The coordinator's `build_final_error` method determines how the validation
tree gets transformed into the final error structure returned by `to_result`.

The validator maintains errors as a tree where each node holds its own errors
plus references to invalid child nodes. The coordinator's `build_final_error`
method determines how the tree gets transformed into the final error
structure returned by `to_result`. Different applications need different final formats.

**Hierarchical Strategy** (`Coordinator::Errors::Hierarchical`)
Preserves the tree structure as nested hashes — most natural for debugging:

```ruby rspec with_hierarchical_adapter
expected_failure = {
  errors: [root_error],
  children: {
    foo: { 
      children: {
        bar: { errors: [bar_error] }
      }
    }
  }
}
expect(result.to_result.failure).to eq(expected_failure)
```

**Flat Strategy** (`Coordinator::Errors::Flat`)
Flattens errors into path-value tuples — useful for processing or storage:

```ruby rspec with_flat_adapter
expected_failure = [
  ['', [root_error]],
  ['foo.bar', [bar_error]]
]
expect(result.to_result.failure).to eq(expected_failure)
```

**Dry Strategy** (`Coordinator::Errors::Dry`)
Mimics `Dry::Validation` error format for compatibility:

```ruby rspec with_dry_adapter
expected_failure = [
  [root_error], 
  foo: {
    bar: [bar_error]
  }
]
expect(result.to_result.failure).to eq(expected_failure)
```

Choose the strategy that best fits your application's error handling patterns,
or implement custom strategies for specialized formats.

### Interfaces
The library communicates with your application through two key types:

- **Result** - Wraps the final validation outcome (success or failure)
- **Option** - Represents values that may or may not be present
(used with `validate?` and missing value strategies)

Both types are configurable to match your existing codebase's patterns.

**Default Interface**
The library includes basic implementations at `Lite::Validation::Validator::Adapters::Interfaces::Default`.
These are primarily intended for internal use but can be configured as external interfaces too.
They may provide a good enough solution when you want to avoid dependencies 
but lack monadic functionality and may feel awkward compared to more advanced 
alternatives.

**Dry::Monads Integration**
The recommended approach uses `Dry::Monads`:
- **Result**: Uses `Dry::Result` for success/failure outcomes
- **Option**: Uses `Dry::Result::Failure(Unit)` to represent missing values
(rather than `Dry::Maybe`, since `Maybe::Some` cannot hold `nil` values)

**Custom Interfaces**
Build custom interface adapters to integrate with your preferred flow control libraries.
This lets the validation library work seamlessly within your existing error
handling and optional value patterns. The interface configuration ensures the library adapts
to your codebase rather than forcing architectural decisions on your application.

# License
This library is published under MIT license

