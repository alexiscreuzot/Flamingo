[![Language](https://img.shields.io/badge/swift-4-orange.svg)](http://swift.org)
[![Build Status](https://travis-ci.org/kirualex/Flamingo.svg?branch=master)](https://travis-ci.org/kirualex/Flamingo)

# Flamingo
Minimalist Hacker News Reader

<p align="center">
  <img src="https://i.imgur.com/fUstrhJ.png" style="max-height:400px;">
</p>

## Purpose
I'm an avid reader of Hacker News, which to me is one of the best news aggregator in relation to my interests (Tech, Science, World News). HN as some flaws though :
- It doesn't provide any excerpt or summary
- There are no images
- There are no indicator of article length
- It's overall quite unappealing to the reader

The purpose of this project is to provide the best experience possible for reading HN top stories, similar to what Yahoo Digest did offer before being discontinued. I've open-sourced both the code and the design file (.sketch).

You can find this app on the AppStore here : https://itunes.apple.com/app/id817164332

## Current features
Here is what the app currently does :
- [x] Fetch HN top stories.
- [x] Get curated previews of each story through [Mercury API](https://mercury.postlight.com/).
- [x] Downloads stories images. When the first one (with high enough quality) finished to load we make it our header.
- [x] Display stories "readtime" based on the content word count.
- [x] Display comments of a story.
- [x] Show individual stories using `SFSafariViewController` with reader mod on.
- [x] Indicate already read stories (thanks to @iGranDav)

## Roadmap
There are a lot of ways to improve the experience even further. I'm open to any ideas the community may have!
Here are a few :
- [ ] Custom reader to replace `SFSafariViewController`
- [ ] Switch between top and new stories

## One more thing
Flamingo, what a cool name! How did I find it you ask? I actually used [the Qolor app](https://itunes.apple.com/app/id973492333) on the Hacker News orange, and it was the result :)
