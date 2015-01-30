---
layout: default
title: Meetups
permalink: /meetups/
---

# Meetups

{{ site.location }}

Visit the [meetup page](http://www.meetup.com/Brisruby/) for more details

{% for meetup in site.meetups reversed %}

  {% include meetup.html %}

{% endfor %}
