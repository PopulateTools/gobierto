# Gobierto template engine

[Liquid](https://github.com/Shopify/liquid) is very popular template engine written to be simple and secure. Gobierto implements a few Liquid tags to embed dynamic content in the site HTML blocks. In the future, all Gobierto templates will be fully customizable using Liquid and the administrator UI.

This is a work in progress, we'll be implementing more tags and the possibility of editing a template through the admin UI.


## list_children_pages

In the context of a CMS section, it renders the children pages of the given page.

- Arguments:
  - `page-slug`: the slug of the page whose children will be shown
  - `levels`: the number of levels that will be rendered. Default: 1 (first level)

- Usage: `{% list_children_pages page-slug | levels: 1 %}`

- Returns:

```
<div class="page_children">
  <div class="page_child">
    <a href="http://madrid.gobierto.dev/s/participacion/sobre">Sobre Nosotros</a>
    <div class="page_children">
      <div class="page_child">
        <a href="http://madrid.gobierto.dev/s/participacion/segundo-nivel">Segundo nivel</a>
        <div class="page_children">
          <div class="page_child">
            <a href="http://madrid.gobierto.dev/s/participacion/tercer-nivel">Tercer nivel</a>
          </div>
        </div>
      </div>
    </div>
  </div>
</div>
```


## page_title

Renders the title of a page (an instance of`GobiertoCms::Page`)

- Arguments:
  - `slug`: the slug of the page

- Usage: `{% page_title about %}`

- Returns: "About page"

## page_url

Renders the path of a page (an instance of`GobiertoCms::Page`)

- Arguments:
  - `slug`: the slug of the page

- Usage: `{% page_url about %}`

- Returns: "/paginas/about"

## Available templates

### GobiertoParticipation home

It is available as template GobiertoParticipation home (gobierto_participation/welcome/index.liquid)
