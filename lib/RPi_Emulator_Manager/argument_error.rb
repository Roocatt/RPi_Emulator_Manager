# frozen_string_literal: true

class ArgumentError < StandardError
  def initialize(msg = nil)
    super(msg)
  end
end
