---
title: "20230921 GitHub as Comments Engine?"
date: 2023-09-20T22:55:17-04:00
draft: false
---

# A smaller internet for end users

You know what I hate? When my perfectly fast computer struggles to render a web page which perhaps is giving me 1KB of useful information. Why is it faster for me to access the entire [awesome CS book](https://web.mit.edu/6.001/6.037/sicp.pdf "awesome CS book") than it is to read two email messages on gmail? Why does my computers fan come on rendering the YouTube home page?

** Bloated JavaScript Hell **

These pages are chock full of scripts doing nothing to help me, telling Google where on the page I've spent more time, what emails my cursor has hung over and what my father had to tell me this week.

The question continues, why do people need computers with 600 watt power supplies to play games which for the most part are the same as they were 15 years ago. Looking at you Call of Duty. 

** Bloated C++ Hell **

Half the games created now are based on Unity. Who are [shitty](https://www.npr.org/2023/09/19/1200415400/unity-engine-price-video-games-developers "shitty") for many reasons. But more importantly are phoning home to give a company who did not create your game telemetry about your usage. Other games are logging your actions to figure out what micro transactions to advertise to you.

In short, half the time your computer is doing absolutely nothing you asked it to. Wouldn't it be great if your ten year old computer could still be used? Wouldn't it be awesome if we did not literally melt the ice caps so that Activision can sell you paint for your virtual P90 sub-machine gun? 

I mean we can, tons of tools exist to produce a smaller more efficient internet. Once that you can have higher control over. People [write](https://benhoyt.com/writings/the-small-web-is-beautiful/ "write") about it beautifully.

# My new project

One common theme promoted in the small web is to offload work to the server side. Have something prepared once, efficiently at a centralized location that can have optimal cooling and power management. It can be more efficient allowing less load on clients.

Another common theme is static site generation. This site uses Hugo to that end. It publishes to a GitHub pages site but really it could go anywhere. One failure of the static websites is a lack of comments. Comments and threaded discussion generally is the space of JavaScript. Hugo allows for extensions like Disqus to be added but that's not "very small". It's certainly not offloading work to the server when we have bloated editors, auto-save and who knows what else the third party does while you post their JavaScript code on your page.

What has user credentials, free and efficient text tracking and an approval / moderation process? Even better most tech nerds have an account on it already.

Git and GitHub

What if comments on a static site could also be generated statically on the web page? Users could submit comments through GitHub as a PR. Once vetted and merged they could simply be integrated with the page on render. Using GitHub actions and Hugo it should be fairly easy to assemble. The comments would be able to be ported to any other git hosting should GitHub go down the tubes.

I'll try to set this up over the coming days. It would be nice to see if anyone is visiting these pages and engage.

Later
