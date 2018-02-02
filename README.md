# Flamingo
Minimalist Hacker News Reader

<br/>
<p align="center">
  <img src="https://i.imgur.com/rYp9ajL.png" height="500">
</p>

## Purpose
I'm an avid reader of Hacker News, which to me is one of the best news aggregator in relation to my interests (Tech, Science, World News). HN as some flaws though :
- It's ugly as hell
- It only show titles and source
- Overall, it's not very appealing

The purpose of this project is to provide the best experience possible for reading HN top stories.

## Basic principle
Here is what the app currently does :
- [x] Fetch HN top stories
- [x] Get curated previews of each story through [Mercury API](https://mercury.postlight.com/)
- [x] Load sotries images and grab the first to finish. This is our head article
- [x] Display stories "readtime" based on the content word count
- [x] Show individual stories using `SFSafariViewController` with reader mod on

## Roadmap
There are a lot of ways to improve the experience even further. I'm open to any ideas the community may have!
Here are a few :
- [ ] Display individual stories in custom webview
- [ ] Provide a way to switch between top and new stories
- [ ] Allow infinite loading
