---
date: "2012-12-11"
slug: "testing-testing"
tags: ["testing"]
title: "Testing, Testing"
---

I had the opportunity to attend a [Global Day of Coderetreat](http://www.coderetreat.org) event this past weekend. I came in with few expectations(beyond seeing a neckbeard or two). There was quite a variety of platforms, programming languages, and age. And there were even females! The skill focus was on Test Driven Development(TDD). We formed pairs(preferably with a person with a language in common, but not always) several times throughout the day and worked on implementing Conway's Game of Life. I wrote in Python several times, worked with a guy writing in C#, and another guy writing in Ruby. It was nice to have exposure to unknown languages and certainly a welcome change of pace. C# felt especially different to me because of all the type declarations.

For those unfamiliar with Conway's Game of Life it plays out as such: There are adjacent cells that multiply and die between generations. Each cell has a defined space(let's say a coordinate) and its future existence depends upon the number of neighboring cells it has. A cell will spontaneously generate if there are two or three live adjacent cells. Likewise, a live cell will survive to the next generation if it has either two or three live adjacent cells. Live cells with none, one, or more than three live neighbors will die going into the next generation. Lastly, a cell that just died the previous generation can be brought back to life if its remains have exactly 3 surrounding live cells.

There are a number of implementations of it shown on Youtube. It eventually turns into interesting patterns flying around. Some of them turn into little motionless enclaves and others shoot off like spaceships; some of them are mesmerizing to watch. None of our implementations got this far(to my knowledge), but there was a fair bit of discussion about how to devise the implementation.

I think my favorite implementation was using sets to determine which cells should live or die. All of the coordinates of live cells are put into a set. Let's call this set L. Then for each live cell, each of the eight neighboring coordinates are put into a set. For each set of neighboring coordinates to a live cell an intersection is made with set L to determine live neighbors.

Some other implementations were to run a decision on every single coordinate based on its surrounding coordinates(significantly more computationally intensive) or running a decision on every single coordinate within an expanding boundary of coordinates(think of the edge of the universe expanding as galaxies accelerate away from the big bang). In one of my groups we decided we should make our board a pacman-style looping surface, which would make the computations significantly shorter.

Proper test driven development is interesting. I had never written tests _before_ writing code, but it seemed interesting. And certainly beneficial. Frequently when I am devising how I want a piece of code to work I will work out the edge cases in my head, similar to how TDD should work. I get the feeling if you use TDD regularly you will think like this all of the time.

We also had some “exciting” twists to our development during several of the pairs. For instance, for one of them we could not write methods longer than four statements. For another round there was a time limit between writing a test, failing it, and implementing a solution to the test. In another round the code writer couldn't speak or write to the test writer(this was my favorite). And in the worst one we were not allowed to use any return statements.

All in all, I highly recommend going to these sorts of events. This was my first one and I definitely plan to go to more!

I originally intended to touch on browser testing in this post as well but I think I will save it for another entry. In the meanwhile, Selenium is an interesting tool that fires up a real browser in order to test webpages. I learned about this at the Pittsburgh Python group and was intrigued. More on this next time!!