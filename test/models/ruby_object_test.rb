# frozen_string_literal: true

require "test_helper"

class RubyObjectTest < ActiveSupport::TestCase
  def setup
    @constant = "String"

    attributes = {
      name: "String",
      description: "<h1>Hello World</h1>",
      object_type: "class_object",
      constant: @constant,
      superclass: "Object",
      included_modules: ["Kernel"],
      metadata: {
        depth: 1
      },
      methods: [
        {
          name: "new",
          description: "<h1>Hello World</h1>",
          method_type: "class_method",
          object_constant: "String",
          source_location: "2.6.4:string.c:L28",
          metadata: {
            depth: 1
          },
          call_sequence: <<~G
            String.new # => ""
          G
        },
        {
          name: "to_i",
          description: "<h1>Hello World</h1>",
          method_type: "instance_method",
          object_constant: "String",
          source_location: "2.6.4:string.c:L54",
          metadata: {
            depth: 1
          },
          call_sequence: <<~G
            str.to_i # => 1
          G
        }
      ]
    }

    @object = RubyObject.new attributes
  end

  test "requried attributes" do
    assert_equal @object.name, "String"
    assert_equal @object.object_type, "class_object"
    assert_equal @object.constant, "String"
    assert_equal @object.superclass, RubyObject.new(constant: "Object")
    assert_equal @object.included_modules, [RubyObject.new(constant: "Kernel")]
    assert_equal @object.description, "<h1>Hello World</h1>"
  end

  test "#==" do
    assert_equal @object, RubyObject.new(constant: @constant)
  end

  test "#id" do
    assert_equal @object.id, "c3RyaW5n"
  end

  test "#class_method?" do
    object = RubyObject.new(object_type: "class_object")
    assert_equal object.class_object?, true
  end

  test "#module_object?" do
    object = RubyObject.new(object_type: "module_object")
    assert_equal object.module_object?, true
  end

  test "ruby_methods" do
    assert_equal @object.ruby_methods.all? { |m| m.is_a?(RubyMethod) }, true
  end

  test "ruby_class_methods" do
    assert_equal(
      @object.ruby_class_methods.all? { |m| m.is_a?(RubyMethod) },
      true
    )
    assert_equal @object.ruby_class_methods.all?(&:class_method?), true
  end

  test "ruby_instance_methods" do
    assert_equal(
      @object.ruby_instance_methods.all? { |m| m.is_a?(RubyMethod) },
      true
    )
    assert_equal @object.ruby_instance_methods.all?(&:instance_method?), true
  end

  test "#to_hash" do
    assert_equal @object.to_hash, {
      id: "c3RyaW5n",
      name: "String",
      type: :object,
      autocomplete: "String",
      constant: "String",
      object_type: "class_object",
      description: "<h1>Hello World</h1>",
      superclass: "Object",
      included_modules: ["Kernel"],
      metadata: {
        depth: 1
      },
      methods: [
        {
          name: "new",
          description: "<h1>Hello World</h1>",
          type: :method,
          autocomplete: "String::new",
          object_constant: "String",
          identifier: "String::new",
          method_type: "class_method",
          source_location: "2.6.4:string.c:L28",
          metadata: {
            depth: 1
          },
          call_sequence: <<~G
            String.new # => ""
          G
        },
        {
          name: "to_i",
          description: "<h1>Hello World</h1>",
          type: :method,
          autocomplete: "String#to_i",
          object_constant: "String",
          identifier: "String#to_i",
          method_type: "instance_method",
          source_location: "2.6.4:string.c:L54",
          metadata: {
            depth: 1
          },
          call_sequence: <<~G
            str.to_i # => 1
          G
        }
      ]
    }
  end
end
