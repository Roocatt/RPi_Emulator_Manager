# frozen_string_literal: true

class ImageError < StandardError
  attr_reader :image_file

  def initialize(msg = 'Image Error', image_file = nil)
    super(msg)
    @image_file = image_file
  end
end
