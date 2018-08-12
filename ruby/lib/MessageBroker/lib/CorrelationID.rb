require "securerandom"

class CorrelationID 
  def self.create
    SecureRandom.random_number(36**12).to_s(36).rjust(16, "0")
  end
end