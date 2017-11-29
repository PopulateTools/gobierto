![Gobierto](https://gobierto.es/assets/logo_gobierto.png)

# Gobierto template engine

[Liquid](https://github.com/Shopify/liquid) is very popular template engine written to be simple and secure.

Gobierto implements a few Liquid tags to embed dynamic content in the site HTML blocks and templates will be fully customizable using Liquid and the administrator UI.

## Available liquid tags

### page_title

Renders the title of a page (an instance of`GobiertoCms::Page`)

- Arguments:
  - `slug`: the slug of the page

- Usage: `{% page_title about %}`

- Returns: "About page"

### page_url

Renders the path of a page (an instance of`GobiertoCms::Page`)

- Arguments:
  - `slug`: the slug of the page

- Usage: `{% page_url about %}`

- Returns: "/paginas/about"

## Available templates

### GobiertoParticipation home

It is available as template GobiertoParticipation home (gobierto_participation/welcome/index.liquid)
