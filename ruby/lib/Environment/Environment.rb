require 'singleton'

APP_ENV = "APP_ENV"

# Example: Environment.instance.development?

class Environment
  include Singleton

  def development?
    return ENV[APP_ENV] == "development"
  end

  def stage?
    return ENV[APP_ENV] == "stage"
  end

  def production?
    return ENV[APP_ENV] == "production"
  end
end