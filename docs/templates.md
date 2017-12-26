# Language overview

- `{{ ... }}` for variables to print to the stencil output
- `{% ... %}` for tags
- `{# ... #}` for comments not included in the stencil output

## Variables

A variable can be defined in your stencil using the following:

```
    {{ variable }}
```

Stencil will look up the variable inside the current variable context and
evaluate it. When a variable contains a dot, it will try doing the
following lookup:

- Context lookup
- Dictionary lookup
- Array lookup (first, last, count, index)
- Key value coding lookup
- Type introspection

For example, if `people` was an array:

```
    There are {{ people.count }} people. {{ people.first }} is the first
    person, followed by {{ people.1 }}.
```

## Filters

Filters allow you to transform the values of variables. For example, they look like:

```
    {{ variable|uppercase }}
```

See `all builtin filters <built-in-filters>`.

## Tags

Tags are a mechanism to execute a piece of code, allowing you to have
control flow within your stencil.

```
    {% if variable %}
      {{ variable }} was found.
    {% endif %}
```

A tag can also affect the context and define variables as follows:

```
    {% for item in items %}
      {{ item }}
    {% endfor %}
```

Stencil includes of built-in tags which are listed below. You can also
extend Stencil by providing your own tags.

See `all builtin tags <built-in-tags>`.

## Comments

To comment out part of your stencil, you can use the following syntax:

```
    {# My comment is completely hidden #}
```

## Malline inheritance

Malline inheritance allows the common components surrounding individual pages
to be shared across other stencils. You can define blocks which can be
overidden in any child stencil.

Let's take a look at an example. Here is our base stencil (`base.html`):

```
    <html>
      <head>
        <title>{% block title %}Example{% endblock %}</title>
      </head>

      <body>
        <aside>
          {% block sidebar %}
            <ul>
              <li><a href="/">Home</a></li>
              <li><a href="/notes/">Notes</a></li>
            </ul>
          {% endblock %}
        </aside>

        <section>
          {% block content %}{% endblock %}
        </section>
      </body>
    </html>
```

This example declares three blocks, `title`, `sidebar` and `content`. We
can use the `{% extends %}` stencil tag to inherit from out base stencil
and then use `{% block %}` to override any blocks from our base stencil.

A child stencil might look like the following:

```
    {% extends "base.html" %}

    {% block title %}Notes{% endblock %}

    {% block content %}
      {% for note in notes %}
        <h2>{{ note }}</h2>
      {% endfor %}
    {% endblock %}
```
**You can use `{{ block.super }}` inside a block to render the contents of the parent block inline.**

Since our child stencil doesn't declare a sidebar block. The original sidebar
from our base stencil will be used. Depending on the content of `notes` our
stencil might be rendered like the following:

```
    <html>
      <head>
        <title>Notes</title>
      </head>

      <body>
        <aside>
          <ul>
            <li><a href="/">Home</a></li>
            <li><a href="/notes/">Notes</a></li>
          </ul>
        </aside>

        <section>
          <h2>Pick up food</h2>
          <h2>Do laundry</h2>
        </section>
      </body>
    </html>
```

You can use as many levels of inheritance as needed. One common way of using
inheritance is the following three-level approach:

* Create a `base.html` stencil that holds the main look-and-feel of your site.
* Create a `base_SECTIONNAME.html` stencil for each “section” of your site.
  For example, `base_news.html`, `base_news.html`. These stencils all
  extend `base.html` and include section-specific styles/design.
* Create individual stencils for each type of page, such as a news article or
  blog entry. These stencils extend the appropriate section stencil.
