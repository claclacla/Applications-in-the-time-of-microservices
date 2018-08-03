require_relative "./Environment/Environment"

def config
  file = nil

  if Environment.instance.development?
    file = "../../../config.development.json"
  elsif Environment.instance.stage?
    file = "../../../config.stage.json"
  elsif Environment.instance.production?
    file = "../../../config.production.json"
  end

  configFilePath = File.expand_path(file, __FILE__)
  configFile = File.read configFilePath
  config = JSON.parse(configFile)

  return config
end