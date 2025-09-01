---
title: "20250831 Emacs On Android is WERID"
draft: false
---

# Summertime

I've been away from my desk more and more as of late. Summer sun has been good to me spoiling me with choices of activities. There is a variety ranging from wanting to spend time with my dog, to actually being healthy and riding my bike frequently. All of these conspire _thankfully_ to keep me away from my computer. I've even been playing guitar more. These are all good things. While I could tote a laptop with me on these adventures I've not been.

And frankly that's probably good.

I have to put my ass in a chair too much to pay the bills. One thing that was not super evident to me was how bad my office work and coding career is for overall health. I kept `active` but not enough. A few gym trips a month may keep you not deceased but it is not good to couple sitting at your desk coding followed by hours more tinkering, coding and gaming. I've been getting outside more and more over the past few years and its been amazing for my body and my mind. 

Trust me when I say that:

![A snoopy painting on the side of a red barn in the sun](/me/20250831/snoop.jpeg)

Huffing it up the hill to see this guy is mind expanding. Or at least it will make your legs hurt! It's fun to go see places you drank yourself stupid at when you were twenty:

![The entrance to wonder bar in Asbury Park NJ](/me/20250831/asbury.jpeg)

The problem is, I want my cake and to eat it too, I realize that my metaphorical cake will probably need to be shelf stable and maybe not quite as good as my nice laptop with zsh and emacs and games but I want to be able to write and think and blog and whatnot on the go. So I finally decided to do it, try to care about a mobile device. Maybe I could be one of these `Ipad Only` folks I see on [The Internets](https://www.macstories.net) or something else like that.

# Enshittification

[iykyk](https://en.wikipedia.org/wiki/Enshittification)

Oh yea no. So trying to use my collection of mobile devices:

- A new-ish iphone
- A not new ipad mini
- A not so old android phone (used pixel 8a)

for more than a brief call I found out one thing. They fucking suck. What is a computer you can't run bash on? What on earth are these OS services sending me AI summaries of 2 line text messages? Why the fuck is my phone telling google random shit? 

For the average internet user, who is using it through these devices, its really not the same. The internet is not explorable, they can't try things and its just all around awful. There are some app creators on IOS and Android that try to give reasonable computing environments:

[Code App IOS](https://codea.io)
[Termux App Android](https://play.google.com/store/apps/details?id=com.termux&hl=en-US)

But they seem janky. They are also fly by night and not long lived. Codea I think has been purchased. Termux is open source, but its not bash or emacs. I don't know how much I can trust it.

# Redemption

The one thing we don't hear about when we hear about enshitification, walled gardens etc is the quality of the hardware. No I'm not talking about our blessed apple googles overpriced chips. But I am talking about computers that can go places. I can take Iphones or some Android phones out on a bike in the pouring rain and they will live. I can take them to the park for 10 hours and I still can checek the weather. I can drop them and they live on. 

Similarly while IOS and Android both do creepy shit there seem to be android forks like [Graphene](https://grapheneos.org) that are more sane.

# What remains

![Emacs With EShell showing on an android phone](/me/20250831/phone_screenshot.png)

Yea now we're talking the right kind of crazy. I've flashed that android phone with graphene, locked it down to the point a bank wouldn't touch me and installed emacs on it. It's weird. Emacs knows its on android, has android touch handling and is generally freaky to have on a phone. I'm messing with it now. The troubles start with how emacs on android and android works. Android has apps sandboxed so emacs really can't find say a git executable. There are some documentation call outs on [the emacs manual](https://www.gnu.org/software/emacs/manual/html_node/emacs/Android-Software.html) but its a bit unclear. It seems like you can do some forgery and cross app hackery to let emacs see termux. There are [some users](https://sourceforge.net/projects/android-ports-for-gnu-emacs/files/termux/) who have patched things up for you to try, but again this seems hacky. I think I can also probably try to compile the things I want, like git and openssh and place them in emacs's context on android.

That's what will be next, for now I'm enjoying trying to get this piece of shit phone to be an actual sensible computer.
