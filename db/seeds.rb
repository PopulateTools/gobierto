## Órgiva
place = INE::Places::Place.find_by_slug 'orgiva'

site = Site.find_or_create_by! name: 'Órgiva Participa', domain: 'orgiva.gobierto.dev', location_name: 'Órgiva', location_type: place.class.name,
  external_id: place.id, institution_url: 'http://orgiva.es', institution_type: 'Ayuntamiento'

site.configuration.links = ['http://orgiva.es']
site.configuration.logo = 'http://www.aytoorgiva.org/web/sites/all/themes/aytoorgiva_COPSEG/logo.png'
site.configuration.demo = true
site.configuration.modules = ['GobiertoBudgets']
site.save!

## Burjassot
place = INE::Places::Place.find_by_slug 'burjassot'

site = Site.find_or_create_by! name: 'Burjassot Transparente', domain: 'gobierto.burjassot.dev', location_name: 'Burjassot', location_type: place.class.name,
  external_id: place.id, institution_url: 'http://burjassot.es', institution_type: 'Ayuntamiento'

site.configuration.links = ['http://burjassot.es']
site.configuration.logo = 'http://www.burjassot.org/wp-content/themes/ajuntament/images/_logo-burjassot.jpg'
site.configuration.modules = ['GobiertoBudgets']
site.save!

## Santander
place = INE::Places::Place.find_by_slug 'santander'

site = Site.find_or_create_by! name: 'Santander Participa', domain: 'santander.gobierto.dev', location_name: 'Santander', location_type: place.class.name,
  external_id: place.id, institution_url: 'http://santander.es', institution_type: 'Ayuntamiento'

site.configuration.links = ['http://santander.es']
site.configuration.logo = 'http://santander.es/sites/default/themes/custom/ayuntamiento/img/logo-ayto-santander.png'
site.configuration.modules = ['GobiertoBudgets']
site.save!

## Madrid
place = INE::Places::Place.find_by_slug 'madrid'

site = Site.find_or_create_by! name: 'Madrid', domain: 'madrid.gobierto.dev', location_name: 'Madrid', location_type: place.class.name,
  external_id: place.id, institution_url: 'http://www.madrid.es', institution_type: 'Ayuntamiento'

site.configuration.links = ['http://www.madrid.es']
site.configuration.logo = 'http://www.madrid.es/assets/images/logo-madrid.png'
site.configuration.modules = ['GobiertoBudgets']
site.save!
