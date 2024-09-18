# frozen_string_literal: true

module RedmineAmznAlbAuthn
  Error = Class.new(StandardError)
  InvalidSignerError = Class.new(Error)
end
