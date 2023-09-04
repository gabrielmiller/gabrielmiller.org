---
date: "2013-07-12"
slug: "testing-at-the-resumator"
tags: ["testing"]
title: "Testing at the Resumator"
---

Recently at work I was tasked with creating a customer-facing self-service billing utility. Given the complexity required in the spec, testing was bound to be a pain in the butt. Further, because billing is such an important piece of a web application the testing had to be very thorough.

My coworker and I(just the two of us were tasked to the project) began development using manual testing. After a couple weeks we started to automate test cases with a bit of JavaScript injection--a checklist that sits in an outer frame and injects javascript into an inner frame and drives it around a website, checking off things that it's doing on the list as the browser does the actions within the frame. It was pretty cool--you could run the automation in any modern browser, including on phone and tablets,--but we ran into complications with injecting JavaScript into HTTPS pages. In came Selenium-WebDriver. If you'll recall I mentioned Selenium back in December 2012, when I was first introduced to it. I was vaguely familiar with it and it sounded like something very useful for our project.

After a short while we transitioned our tests to Selenium-WebDriver scripted with Ruby. It doesn't run on as many devices as our previous solution, but it doesn't have HTTPS problems. I initially wrote my test code in Python but transitioned to Ruby since several of my coworkers were more familiar with it and it would be easier to teach them to use Selenium. In hindsight we should have probably gone with PHP since our site is built on PHP, but that's for another discussion. Selenium has been a boon to productivity for us. While I will admit the Selenium-WebDriver gem has very verbose actions, our test suite still has been surprisingly easily maintainable, even beyond 1000 lines of code.

We're still using some in house solutions for unit testing. I think our next step will be putting together a suite of tests in PHPUnit. Eventually it would be great to get a Continuous Integration system rolling, but that may still be quite a ways away. I'd love to see more testing in place.