---
date: "2012-05-05"
slug: "new-undertakings"
tags: ["learning", "web development"]
title: "New Undertakings"
---

I've beefed up my effort to learn PHP recently and I must say I'm extremely grateful to have an understanding of programming from Python's perspective. PHP seems so far to be similar. No doubt the data structures are very similar. And I'm finding the syntax to look much like javascript. Lots of curly braces and semicolons(A foreign concept from a Python background). It seems to have a lot more hodge podge, but I enjoy how simple it is to test code in a browser and I'm appreciating its vast amounts of documentation online. In the process I find myself constantly thinking that trial and error learning is a blast.

Speaking of trial and error, I'd like to note that trial and error is one of my favorite things about learning. There's such a thrillingly rewarding feeling to having solved a problem on your own. Today I finally got around to getting my site's contact form actually email me—what seemed at first to require jumping through hoops of fire—was quite simple. It was really a matter of diagnosis: what wasn't working and why it wasn't working? Once that was determined it was just a matter of changing what was happening.

It turned out that I was putting too much faith into recommendations I was reading on the internet and not enough in myself: my webhost apparently used to not support SMTP and there were several workarounds to send outbound email through web services. I mistakenly decided I should try using these workarounds to a no longer existent problem, which led me down a bit of a rabbithole.

But I emerged from the hole eventually. I pulled up Django's python shell and tried importing the smptlib module to send an email with the interpreter. The great thing about interpreters is that you can instantly find errors on a line by line basis. I input my mail account, host, port, password, etcetera to discover that indeed SMTP does work on my host! With this little flash of insight I used django's email capabilities by using a very simple function, send_mail, from the django.core.mail module. That too worked! So it was all just a matter of discovering what exact code needed to go into my view—simple enough!

All in all, it turns out complex problems are much simpler to solve with Python than at first might be expected. It's a matter of learning what approach to take. I'm learning this over and over again. I must say, I am feeling quite euphoric about solving my own problems. It reminds me of learning a new skill. When I was a kid I taught myself how to stilt-walk. At first I could not so much as take a step, but after thousands of times stepping onto the stilt and falling over I was able to take a step. And then two. Three. My brain was adjusting to the new feedback. It's a snowballing effect, and it's delightful.

More another day!