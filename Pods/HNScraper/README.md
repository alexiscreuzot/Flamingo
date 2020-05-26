# HNScraper

<p align="center">
    <a href="https://travis-ci.org/tsucres/HNScraper">
      <img src="https://img.shields.io/travis/tsucres/HNScraper.svg">
    </a>
    <img src="https://img.shields.io/badge/Swift-4.0-orange.svg" />
    <a href="https://opensource.org/licenses/MIT">
      <img src="https://img.shields.io/badge/License-MIT-yellow.svg" alt="License" />
    </a>
</p>


HNScraper is a scraping library for hackernews, written in swift. It allows you to fetch all the stories, comments and user informations directly from the website. It also supports logging in and vote on/favorite posts and comments.

This library is similar to the [LibHN](https://github.com/bennyguitar/libHN) library. Actually, some parts of the project, such as the post, comment and user models and the parsing rules are basically a swift translation of the LibHN library.


Before going further, note that there is an [official API](https://github.com/HackerNews/API) that implements the fundamentals features such as grabbing the new, top and best stories, user informations and comments. However, it doesn't support login and any related functionalities and suffers from a lot of restrictions. If it fits your needs though, I would recommend you use the official API over this scraper.


## Table of content

* [Installation](#installation)
* [Documentation](#documentation)
	* [Completion handlers & error gesture](#completion-handlers-&-error-gesture)
	* [Fetch list of posts](#fetch-list-of-posts)
	* [Fetch comments about a post](#fetch-comments-about-a-post)
	* [Fetch informations about a user](#fetch-informations-about-a-user)
	* [Fetch the submissions, comments and favorites of a user](#fetch-the-submissions,-comments-and-favorites-of-a-user)
	* [Login / Logout](#login-/-logout)
	* [Vote on posts/comments](#vote-on-posts/comments)
	* [Favorite a post](#favorite-a-post)
* [Structure of the project](#structure-of-the-project)
* [Contribution](#contribution)
* [TODO](#todo)
* [License](#license)


## Installation

#### Pod

Ensure you have at least the following code in your `Podfile`:

```
use_frameworks!

target 'YourAppName' do
    pod 'HNScraper', '~> 0.2.1'
end
```

Run `pod install` in your project's folder.

Then just add `import HNScraper` wherever you need the scraper.


#### Manually

Just add all the `.swift` files from the `HNScraper` folder in your project.

## Documentation

### Completion handlers & error gesture
All the following actions are performed in the same way: you call a method on the right instance with the required parameters and a completion handler which will give you back the results of your request and, eventually, the produced error.

```swift
func getSomething(dependingOn: , completion: ((results?, error?) -> Void))
```

The possible errors are defined by `HNScrapperError ` and `HNLoginError `. Those structures simplifies the error handling by classifying the most recurrent errors into distinct, self-explanatory error types. This abstraction allows you to handle common problems, such as no Internet connection, bad credentials, non-existing post-id, etc, without worrying about "low level" errors such as URLErrors and JSON errors.


### Fetch list of posts
A list of posts is any of the HN pages defined in `HNScraper.PostListPageName`

[`news`](https://news.ycombinator.com/news)
[`front`](https://news.ycombinator.com/front)
[`new`](https://news.ycombinator.com/newest)
[`jobs`](https://news.ycombinator.com/jobs)
[`asks`](https://news.ycombinator.com/ask)
[`shows`](https://news.ycombinator.com/show)
[`newshows`](https://news.ycombinator.com/shownew)
[`active`](https://news.ycombinator.com/active)
[`best`](https://news.ycombinator.com/best)
[`noob`](https://news.ycombinator.com/noobstories)       

To scrap the 30 first posts of one of them, you have to use `getPostsList` (from `HNScraper`) which will give you an array of `HNPost` objects and the link to the next page that you can use to fetch the 30 following items. 

```swift
typealias PostListDownloadCompletionHandler = (([HNPost], String?, HNScrapperError?) -> Void)

func getPostsList(page: PostListPageName, completion: PostListDownloadCompletionHandler)
```

For example:
 
```swift
HNScraper.shared.getPostsList(page: .news) { (posts, linkForMore, error) in
	// Don't forget to handle the eventual error
	for post in posts {
		print(post.title)
	}
	// You also may want to save the linkForMore somewhere.
}
```

For the 30+ items, you have to use `getMoreItems` at which you pass the "link for more" you got with the 30 first items. This will also give you a list of `HNPost` instances and a link for the next page: 

```swift
func getMoreItems(linkForMore: String, completionHandler: PostListDownloadCompletionHandler) 
```

For example: 

```swift
HNScraper.shared.getMoreItems(linkForMore: "s") { (posts, linkForMore, error) in
	// do whatever you want with the stories
}

```





### Fetch comments about a post
The comments are parsed from a discussion thread (at `news.ycombinator.com/item?id=`*`<post_id>`*). You can fetch those in 2 ways: either with 

```swift
func getComments(ByPostId postId: String, buildHierarchy: Bool = true, completion: @escaping ((HNPost?, [HNComment], HNScraperError?) -> Void))
```

or with 

```swift
func getComments(ForPost post: HNPost, buildHierarchy: Bool = true, completion: @escaping ((HNPost, [HNComment], HNScraperError?) -> Void))
```


The parameter `buildHierarchy` indicates if the comments have to be returned in nested (meaning that only the root comments are in the resulting array and they are pointing to their replies) or in linear (flat) format.

With the `ByPostId` method, the data about the post itself will be parsed to build a `HNPost` object that is passed to the completion closure.

With the `ForPost`method, the `HNPost` instance given to the completion closure is the same (unmodified) post you passed to the `getComments`method. 


For a `askHN` type of posts, the first comment is the OP's ask itself.

As for `job` type of posts, there should be no comments.

### Fetch informations about a user
You can get the karma, description and age of any user by giving its username to the `getUser`method: 

```swift
func getUserFrom(Username username: String, completion: ((HNUser?, HNScraperError?) -> Void)?)
```

### Fetch the submissions, comments and favorites of a user

Use the following methods (from `HNScraper`) according to which list you want to grab:

```swift
func getFavorites(ForUserWithUsername username: String, completion: @escaping PostListDownloadCompletionHandler)

func getSubmissions(ForUserWithUsername username: String, completion:  PostListDownloadCompletionHandler)
``` 


In the same way as for the list of post described earlier, the completion closure will give you a "link for more" that you can use to fetch more items (in the case there are more than 30 items to fetch of course). You can use the `getMoreItems(linkForMore: completionHandler:)` method as earlier. 



### Login / Logout

Those actions are handled by the singleton class `HNLogin`. 


You can login with

```swift
func login(username: String, psw: String, completion: @escaping ((HNUser?, HTTPCookie?, HNLoginError?) -> Void))
```


Once a user has logged in, the `HNLogin`class takes care to store the session cookie and make it available to the other classes. In addition, with that cookie saved, the html retrieved from the website by any of the requests made by the scrapper will be as if the user was logged in. Which means that it will contain all the upvote (and eventual downvote, if the user has more than 500 points) links, favorite links, comment links, etc. 


The `HNLogin`class comes with its own error enum, `HNLoginError` , which contains the `badCredentials` case. It's returned as an error in the case of, ... well, wrong credentials.

Example: 

```swift
HNLogin.shared.login(username: "username", psw: "pass") { (user, cookie, error) in
	if let connected_user = user {
		print("logged in user: " + connected_user.username)
	} else {
		// Handle error
		if error == .badCredentials {
			print("wrong creds")
		} else {
			// Check other types of error
		}
	} 
}
```

You can logout a user by calling

```swift
func logout()
```

All this method does is delete the stored session cookie, which make the retrieved html from the HN website looking as it would to an unsigned visitor.

### Up/Down/Un vote a post/comment

Simply use one of the following methods: 

```swift
func upvote(Comment comment: HNComment, completion: ((HNScraperError?) -> Void))
func upvote(Post post: HNPost, completion: ((HNScraperError?) -> Void))
func unvote(Post post: HNPost, completion: ((HNScraperError?) -> Void))
func unvote(Comment comment: HNComment, completion: ((HNScraperError?) -> Void))
```

The user obviously needs to be logged in to do that. Otherwise, an error of type `.notLoggedIn` is passed to the completion closure.

If the `error` parameter of the completion closure is `nil`, then the action was succesfull. Otherwise there was a problem. 

**Note**: an action is considered *succesfull* when the final state of the item is the one itended by the request. So if you try to unvote a post that hasn't been upvoted, there will be no error. Same if you try to upvote an upvoted item.



### (Un)Favorite a post

Use: 

```swift
func favorite(Post post: HNPost, completion: ((HNScraperError?) -> Void))
func unfavorite(Post post: HNPost, completion: ((HNScraperError?) -> Void)) 

```


Those methods works in the same ways as the ones for voting on items.


Again, the user needs to be logged in, otherwise an error of type `.notLoggedIn` is passed to the completion closure.

## Structure of the project

### Models

The scraper uses 3 models: 

* `HNPost`
* `HNComment`
* `HNUser`

### Endpoints

There are basically 2 singleton classes that you'll use to make requests: 

- **`HNScraper`**
- **`HNLogin`**

### Parsing configuration file

`hn.json` contains most of the informations needed to parse every HN pages. It was introduced in LibHN to 

Although some things changed/have been added in it, its structure is the same as in LibHN. The following section is an update of the original version of the LibHN documentation.


This file is downloaded and stored by the singleton class `HNParseConfig`. 


### Tests

There are tests for most of the methods in the `HNScraperTests` folder.


# Contribution

Contribution of any kind is welcome. 

If you spot an error, you think of an amelioration, you have a suggestion or you g just open an issue or post directly a PR.

Also, I'm not a native English speaker, so don't hesitate to correct some of my sentences :)

# TODO

- Complete the hn.json config file with the rest of hardcoded strings needed for parsing
- Submit story
- Post comments
- Downvote
- Edit account (about, options, mail, ...)
- Search
- Test for mac os apps


# License

HNScraper is licensed under the standard MIT License.

**Copyright (C) 2017-2018 by Stéphane Sercu**

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
