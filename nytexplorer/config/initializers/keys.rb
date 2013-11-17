API_KEYS = YAML.load_file("#{Rails.root}/config/keys.yml")
SUNLIGHT_API_KEY = API_KEYS["keys"]["sunlight"]
NYT_API_KEY = API_KEYS["keys"]["nyt"]

