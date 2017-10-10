![Gobierto](https://gobierto.es/assets/logo_gobierto.png)

# Gobierto

## Environment variables overview

Gobierto requires a few environment variables to be setup properly in order for the application to run. To help with the setup, a file named `.env.example` has been added to the repository:

```bash
# Rails configuration variables
SECRET_KEY_BASE=
RACK_ENV=development
RAILS_ENV=development
TLD_LENGTH=2
HOST=gobierto.dev
BASE_HOST=gobierto.dev
PORT=3000
RAILS_MAX_THREADS=5

# Poltergeist debug and inspector variables
INTEGRATION_DEBUG=false
INTEGRATION_INSPECTOR=false

# Populate data variables
# - Main endpoint
POPULATE_DATA_ENDPOINT=
# - Suggestion endpoint for municipalities suggestion
MUNICIPALITIES_SUGGESTIONS_ENDPOINT=

# Elastic search URL
ELASTICSEARCH_URL=http://localhost:9200

# Redis instance URL
REDIS_URL=redis://localhost:6379/0

# Rollbar API token (https://rollbar.com)
ROLLBAR_ACCESS_TOKEN=

# Amazon S3 credentials, to upload assets
AWS_ACCESS_KEY_ID=
AWS_SECRET_ACCESS_KEY=
AWS_REGION=eu-west-1
S3_BUCKET_NAME=gobierto-dev

# Google Places API Key, to geolocalize places
GOOGLE_PLACES_API_KEY=

# Algolia search engine configuration (https://www.algolia.com)
ALGOLIA_APPLICATION_ID=
ALGOLIA_API_KEY=
ALGOLIA_SEARCH_API_KEY=

# Action mailer config
MAILER_DELIVERY_METHOD=
MAILER_SMTP_ADDRESS=
MAILER_SMTP_USER_NAME=
MAILER_SMTP_PASSWORD=
```

### Rails configuration variables

- `SECRET_KEY_BASE`: Rails secret key base. See `config/secrets.yml`
- `RACK_ENV` and `RAILS_ENV`: Rack and Rails environment
- `TLD_LENGTH`: TLD length setting for the session storage. See `config/initializers/session_store.rb`
- `HOST` and `PORT`: application host and port
- `BASE_HOST`: the application main host. It might be different from host, for example: hosted.gobierto.es vs gobierto.es
- `RAILS_MAX_THREADS`: Puma setting
- `TEST_LOG_LEVEL`: logger level in test environment. Set it to `fatal` to don't log anything.
- `INTEGRATION_INSPECTOR` and `INTEGRATION_DEBUG`: Poltergeist settings to enable the inspector and the debugger. See https://github.com/teampoltergeist/poltergeist#remote-debugging-experimental
- `MAILER_DELIVERY_METHOD`
- `MAILER_SMTP_ADDRESS`
- `MAILER_SMTP_USER_NAME`
- `MAILER_SMTP_PASSWORD`

### Populate Data variables

Populate Data is a tool developed by Populate that stores many of the open date used by Gobierto. Gobierto needs Populate Data to run. If you need access just write us to: `lets@populate.tools`

- `POPULATE_DATA_ENDPOINT`: The endpoint of the Populate Data account
- `MUNICIPALITIES_SUGGESTIONS_ENDPOINT`: The endpoint from Populate data with the places autosuggestion

### NoSQL databases

Gobierto uses ElasticSearch and Redis.

- `ELASTICSEARCH_URL`: ElasticSearch endpoint
- `REDIS_URL`: Redis endpoint

### External services

- `ROLLBAR_ACCESS_TOKEN`: Rollbar access token
- `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `AWS_REGION` and `S3_BUCKET_NAME`: Amazon S3 credentials, region and bucket name
- `GOOGLE_PLACES_API_KEY`: Google Places API key
- `ALGOLIA_SEARCH_API_KEY`, `ALGOLIA_APPLICATION_ID`, `ALGOLIA_API_KEY`: Algolia API keys

