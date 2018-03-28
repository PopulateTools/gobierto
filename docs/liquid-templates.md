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

## list_items_from

It renders the items of a collection.

- Arguments:
  - `collection_slug`: the slug of the collection
  - `date`: include the date of the page. Default: true
  - `intro_text`: include the page intro text. Default: true
  - `limit`: number of items. Default: 4
  - `order`: order of items. Values: `ASC` or `DESC`. Default: DESC.

- Usage: `{% list_items_from collection_slug | date: true, intro_text: true, limit: 4, order: DESC %}`

- Returns:

```
<div class="list_items_from_collection">
  <%= link_to 'collection_item' do %>
    <div class="collection_item">
      <img src="http://pam.esplugues.cat/wp-content/uploads/2016/02/Gener15-10885-420x237.jpeg">
      <span class="date">26 feb 16</span>
      <h2>Esplugues aprova el Pla d’Actuació Municipal amb un ampli consens</h2>
      <p class="description">Intro text if configured. Intro text if configured. Intro text if configured. Intro text if configured. Intro text if configured. Intro text if configured. </p>
    </div>
  <% end %>

  <%= link_to 'collection_item' do %>
    <div class="collection_item">
      <img src="http://pam.esplugues.cat/wp-content/uploads/2016/02/IMG_0505-420x237.jpeg">
      <span class="date">26 feb 16</span>
      <h2>Bon govern i transpàrencia, principal demanda de la ciutadania al procés participatiu del Pla d’Actuació Municipal 2016-2019</h2>
      <p class="description">Intro text if configured. Intro text if configured. Intro text if configured. Intro text if configured. Intro text if configured. Intro text if configured. </p>
    </div>
  <% end %>

  <%= link_to 'collection_item' do %>
    <div class="collection_item">
      <img src="http://pam.esplugues.cat/wp-content/uploads/2015/11/image2.jpg">
      <span class="date">26 feb 16</span>
      <h2>Finalitza el període d’aportacions ciutadanes al Pla d’Actuació Municipal 2016-2019</h2>
      <p class="description">Intro text if configured. Intro text if configured. Intro text if configured. Intro text if configured. Intro text if configured. Intro text if configured. </p>
    </div>
  <% end %>

  <%= link_to 'collection_item' do %>
    <div class="collection_item">
      <img src="http://pam.esplugues.cat/wp-content/uploads/2015/11/image1.jpg">
      <span class="date">26 feb 16</span>
      <h2>Continua obert el període d’aportacions ciutadanes al Pla d’Actuació Municipal 2016-2019, que s’obre al personal de l’Ajuntament</h2>
      <p class="description">Intro text if configured. Intro text if configured. Intro text if configured. Intro text if configured. Intro text if configured. Intro text if configured. </p>
    </div>
  <% end %>
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


## Templates

### gobierto_participation/welcome/index.liquid

Allows for the customization of Gobierto Participation home page

### gobierto_participation/layouts/navigation_process.liquid

Allows for the customization of Gobierto Participation main submenu navigation
