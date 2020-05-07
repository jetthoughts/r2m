# frozen_string_literal: true

MiniTest::Spec.class_eval do
  def self.shared_examples
    warn "FIXME: Remove shared_examples: #{caller(2..2).first}"
    @_shared_examples ||= {}
  end
end

module MiniTest::Spec::SharedExamples
  def shared_examples_for(desc, &block)
    MiniTest::Spec.shared_examples[desc] = block
  end

  def shared_examples(desc, &block)
    MiniTest::Spec.shared_examples[desc] = block
  end

  def include_examples(desc)
    instance_eval(&MiniTest::Spec.shared_examples[desc])
  end
end

Object.class_eval { include(MiniTest::Spec::SharedExamples) }
