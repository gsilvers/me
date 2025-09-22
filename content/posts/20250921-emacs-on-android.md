---
title: "20250921 Emacs on Android Success"
date: 2025-09-21T19:32:12-04:00
draft: false
---

My quest for mobile emacs continues as the days of summer wane. It seems early but the colorful twinge of autumn is showing. Yesterday I joined some coworkers on a nice outing on our bikes. It seemed as though as we rode the first slightly burnt yellows fringed some of the trees. As we completed our 40 miles / 65 kilometers we talked shop a bit and just our interests. It's always interesting to see how people of different ages see the possible future. As we talked I confessed my desire to teach one day when my grey outnumbers my brown. In my head I hoped to be showing my students emacs on whatever devices the future holds.
	
# Tools and Reference

Emacs on android has been a fun adventure over the past month. In some ways I feel I am in love with computing again. My favorite computer of today lets me solve problems where I am wherever I am. I feel like I should give back some perhaps centralize some documentation. Perhaps it will help someone else follow their dreams and get graphical emacs from the park.

When setting up emacs I used a bunch of common tools and android software:
[APK Signer](https://github.com/fornwall/apksigner)
[Termux](https://termux.dev/en/)
[Termux Repo](https://github.com/termux)
[Graphene OS](https://grapheneos.org)

I also partook in some internet discussion and referenced some great articles and posts:
[Emacs Wiki Android Page](https://www.emacswiki.org/emacs/EmacsOnAndroid)
[Wei's Emacs Builds](https://sourceforge.net/projects/android-ports-for-gnu-emacs/files/)
[Kristoffer's Excellent Blog Post](https://kristofferbalintona.me/posts/202505291438/)
[Reddit Discussion On That Post](https://www.reddit.com/r/emacs/comments/1kykjq2/emacs_on_android_is_pretty_good/)
[My Conversation With Prot](https://protesilaos.com/codelog/2025-09-07-prot-asks-greg-emacs-android-fishing-dogs-pennsylvania/)
[Marek's page](https://marek-g.github.io/posts/tips_and_tricks/emacs_on_android/)

All of these really helped me out but a special mention for my conversation with Prot, while I did not "do" or "learn" anything there. The discussion helped settle my resolve to keep working on this.

# Some Notes For Others

The above links can probably get you what you need to get emacs on any android phone. Honestly if you don't care about git and tools just the fdroid app store can get you there. Emacs to me however is part of a pair and its friend is the shell. If you read Kristoffer's blog and poke around you can get emacs integrated with termux for a decent shell environment. 

Android is kind of interesting. Apps a sequestered from one another. They do not see each others files unless you explicitly share them in a linked folder of sorts like home. This means if an app is a terminal emulator like termux, its bash and get and whotnot are not visible to Emacs. This is a security feature designed on top of a linux core. It however is not what emacs expects of a default unix-ey world. It is likely that you could compile binaries statically linked and place them in emacs's folder on android and get around this. You can however trick android. You can sign termux with Emacs's signing key and alter the emacs apk to say it is from the same "sharedUserID" and voila emacs is allowed to read termux's files. This is a bit hacky, I'm  not sure if I will use it forever but it works for now. Now if you are on a newer android install the termux from [Wei's Emacs Builds](https://sourceforge.net/projects/android-ports-for-gnu-emacs/files/) will not work. Here is the process I followed to success on graphene (as of 2025-09-22) running on a pixel 9a.

1. Sign Termux. You need to have termux signed with emacs's key.
   1. Install Termux from fdroid.
   2. In termux install apksigner. `pkg install apksigner`
   3. Download the [termux apk](https://github.com/termux/termux-app/releases)
   4. Download (raw) the [emacs signing key](https://git.savannah.gnu.org/cgit/emacs.git/tree/java/emacs.keystore)
   5. Sign the Termux APK with this something like `apksigner sign --ks -keystore emacs.keystore termux.apk`
   6. Delete your initial termux and install this one
2. Install Git and whatnot in termux `apk install git` and so on...
3. Install emacs.
   1. Download and install the proper emacs build from [Wei's Emacs Builds](https://sourceforge.net/projects/android-ports-for-gnu-emacs/files/termux). This is critical. Wei's emacs builds put the same `sharedUserId` from termux in the emacs `AndroidManifest.xml`. 
4. Configure and use emacs. 
   1. You must have this:
   ```lisp
	   (setenv "PATH" (format "%s:%s" "/data/data/com.termux/files/usr/bin"
		(getenv "PATH")))
		(push "/data/data/com.termux/files/usr/bin" exec-path)
	```

   in your emacs config so your path is right. Then have at it.
   
   
   
# And So On

And that's it so far. This is great. Emacs and frankly programming on a desktop are wonderful. What's better is programming on the go. I've been able to replace [Strava](https://www.strava.com/). 

```lisp
(defun log-bike-ride (duration distance elevation)
  "Prompt for a bike ride log and append it to ~/bike_log.csv.
Prompts for DURATION, DISTANCE, and ELEVATION gained, and appends
a line to the file with today's date."
  (interactive
   (list
    (read-string "Duration (e.g., 1h30m): ")
    (read-string "Distance (km or mi): ")
    (read-string "Elevation gain (m or ft): ")))
  (let* ((date (format-time-string "%Y-%m-%d"))
         (line (format "%s,%s,%s,%s\n" date duration distance elevation))
         (file (expand-file-name "~/bike_log.csv")))
    (with-temp-buffer
      (insert line)
      (append-to-file (point-min) (point-max) file))
    (message "Logged ride on %s." date)))
```

:D

I'm honestly only slightly kidding. Mobile devices are computing for so much more of the world than laptops or desktops. And these devices are SO NOT FREE. Or freeing. Applications like Strava lock users down and if we're not careful our next generations will never know the freedom of a pocket notebook, pen and paper or a computer that they can play with. Emacs and other free software running on portable devices is essential in my eyes to present a gateway drug of configurable computing. 

I hope to play with this more and more to solve my problems, but also hopefully find a way to encourage supporting these devices and their users among the free software community.
