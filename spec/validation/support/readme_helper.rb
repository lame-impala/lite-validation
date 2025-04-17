# frozen_string_literal: true

require 'markly'

module ReadmeHelper
  class Error < StandardError; end

  SPEC_RE = /ruby rspec (\S+)/

  def self.snippets
    @snippets ||= extract_snippets(Pathname.new(__dir__).join('../../../README.md'))
  end

  def self.usage
    @usage ||= Set.new
  end

  def self.snippet!(key)
    raise Error, "Key already used: #{key}" if usage.include?(key)

    snippet(key)
  end

  def self.snippet(key)
    raise Error, "Snippet not defined: #{key}" unless snippets.key?(key)

    usage << key
    snippets[key]
  end

  def self.extract_snippets(path)
    doc = Markly.parse(path.read)
    specs = {}
    doc.walk do |node|
      next unless node.type == :code_block
      next unless (match = SPEC_RE.match(node.fence_info))

      key = match[1].to_sym
      raise Error, "Duplicate spec key: #{key}" if specs.key?(key)

      specs.store(key, node.string_content)
    end
    specs
  end

  def self.ensure_consumed!
    unconsumed = snippets.keys - usage.to_a

    raise Error, "Some snippets were not consumed: #{unconsumed.join(', ')}" unless unconsumed.empty?
  end
end
