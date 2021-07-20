class YamlStore
  attr_reader :db_path

  def initialize(db_path)
    @db_path = db_path
  end

  def load
    File.exist?(db_path) ? YAML.load_file(db_path, fallback: []) : []
  end

  def save(data)
    File.open(db_path, 'w') { |file| file.write data.to_yaml }
  end
end
