# frozen_string_literal: true

class RubyObject
  attr_reader :body

  def initialize(body)
    @body = body
  end

  def self.id_from_path(path)
    Base64.strict_encode64(path)
  end

  def id
    self.class.id_from_path(path)
  end

  def name
    body[:name]
  end

  def path
    constant&.downcase&.gsub(/::/, "/")
  end

  def object_type
    body[:object_type]
  end

  def class_object?
    object_type == "class_object"
  end

  def module_object?
    object_type == "module_object"
  end

  def constant
    body[:constant]
  end

  def description
    body[:description]
  end

  def ruby_constants
    @constants ||= body[:constants].collect { |c| RubyConstant.new(c) }
  end

  def autocomplete
    constant
  end

  def metadata
    body[:metadata]
  end

  def ==(other)
    constant == other.constant
  end

  # This is be empty in search pages
  def ruby_methods
    @ruby_methods ||= body[:methods].collect { |m| RubyMethod.new(m) }
  end

  def superclass
    return @superclass if defined?(@superclass)

    value = body[__method__]
    return unless value

    @superclass = (self.class.new(constant: value) if value)
  end

  def included_modules
    @included_modules ||=
      body[__method__].map { |m| self.class.new(constant: m) }
  end

  def to_hash
    {
      id: id,
      name: name,
      type: :object,
      description: description,
      autocomplete: autocomplete,
      methods: ruby_methods.collect(&:to_hash),
      constant: constant,
      constants: ruby_constants.collect(&:to_hash),
      superclass: superclass&.constant,
      included_modules: included_modules.map(&:constant),
      object_type: object_type,
      metadata: metadata
    }
  end
end
