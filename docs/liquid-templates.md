# Gobierto template engine

We use [Liquid](https://github.com/Shopify/liquid) to allow for the customization of templates through the UI, and providing some tags to make dynamic calls to the application from the Liquid templates. This is a work in progress, we'll be implementing more tags and the possibility of editing a template through the admin UI.

Tags: 

- [image_filter](#image_filter)
- [liquid_i18n](#liquid_i18n)
- [list_children_pages](#list_children_pages)
- [page_title](#page_title)
- [show_poll](#show_poll)

[Templates](#templates)

<hr>


## image_filter

Renders the path of an image

- Usage: `{{ 'Gobierto-Avatar@2x.png' | image_url }}`

- Returns: "/assets/Gobierto-Avatar@2x-3b3e639a0e0ee13213cef48aa336b233072d17689b95887788c48f529e16ddf6.png"

## liquid_i18n

Renders i18n key translation

- Usage `{{ 'gobierto_participation.shared.no_events' | t }}`

- Returns: "No related events"

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
    <a href="http://madrid.gobierto.test/s/participacion/sobre">Sobre Nosotros</a>
    <div class="page_children">
      <div class="page_child">
        <a href="http://madrid.gobierto.test/s/participacion/segundo-nivel">Segundo nivel</a>
        <div class="page_children">
          <div class="page_child">
            <a href="http://madrid.gobierto.test/s/participacion/tercer-nivel">Tercer nivel</a>
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

## show_poll

Renders a poll

- Usage `{% show_poll(poll_id: 62047248) %}` or `{% show_poll() %}`

- Returns: Poll with options

## i18n_locale

Returns the current user locale

- Usage `{% i18n_locale %}`

- Returns: The current locale

## body_css_classes

Returns the css classes necessary for the body to render successfully the page

- Usage `<body class="{% body_css_classes %}" ...>`

- Returns: CSS classes separated by spaces

## Templates

### gobierto_participation/welcome/index.liquid

Allows for the customization of Gobierto Participation home page

### gobierto_participation/layouts/navigation_process.liquid

Allows for the customization of Gobierto Participation main submenu navigation

## Layouts

### layouts/application.liquid

Application layout
