---
title: "20231229 Hugo Errors Ick"
date: 2023-12-29T22:52:55-05:00
draft: false
---

Just a little blurb here. Hugo errors are not the best. I love this tool as it allows me to write a post like this lightening fast. I had done something to my local repo and when I was running `hugo server -D` I was getting just a generic page not found error.

Turns out if you hit that and you're using a theme cloned in as a submodule you should:

1. Run `hugo -v --debug -D` and if you see warnings about a layout not being found:
2. Run `git submodule init && git submodule update` and get your theme repaired.

