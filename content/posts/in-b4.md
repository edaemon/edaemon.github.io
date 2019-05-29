+++ 
draft = false
date = 2019-05-22T14:30:03-07:00
title = "Creating in-b4.com"
description = "Creating in-b4.com using React, Netlify Functions, and FaunaDB"
slug = "" 
tags = [
    "build",
    "frontend",
    "API",
    "Netlify",
    "Lambda",
    "fauna"
]
categories = [
    "Coding"
]
+++

I created [in-b4.com](https://in-b4.com), a simple little web app for the
"[in-b4](https://www.urbandictionary.com/define.php?term=inb4)" internetism. This post has my thoughts on the
process and tools involved.

If you want to check out the code: https://github.com/edaemon/in-b4/

# What and why?

Most people working with web technology have probably heard about [React](https://reactjs.org/). If you haven't,
it's a JavaScript library for creating user interfaces, and it's everywhere. I had heard about React so much I
wanted to learn more about it, so I decided to build something simple with it. I also threw in a few other tools
I'd been planning to tinker with related to the [JAMstack](https://jamstack.org/) architecture.

Why did I choose the "inb4" thing? No real reason other than fitting the parameters: I could build it as a simple app that
referenced a REST endpoint in front of a database.

For some context I'll give an example of how in-b4 is used: if you were to post on Twitter/Reddit/etc.
something like "Star Trek is the best sci-fi series ever made!" you should expect some pushback. Some of that
pushback might be thoughtful, but some of it could be tired and predictable. For instance, someone may make fun
of the [Riker Maneuver](https://memory-alpha.fandom.com/wiki/Riker_Maneuver); to head them off you could
enter a message on in-b4 and append it to your post. For the first hour (or however long you set) nobody will
be able to see what you've entered, but after that hour they'll be able to click on the link like the one below:

https://in-b4.com/233655257752666628

(Just to be clear, I like both Star Trek and Star Wars, and lots of other sci-fi series. Don't hurt me.)

# Tools and technology

While React would provide the frontend application, there were some backend tools I was interested in using:
[Netlify Functions](https://www.netlify.com/docs/functions/) and [FaunaDB](https://fauna.com/).

I was already happy with Netlify's platform (which I was/am using to host this site), and had
previously used [Serverless](https://github.com/serverless/serverless) and [AWS Chalice](https://github.com/aws/chalice)
for building Lambda functions, so Netlify's Functions were an interesting concept. Instead of setting up an AWS account
and workflow to deploy functions, Netlify Functions runs your code in Netlify's account and makes it easy to integrate the
code into your existing build/deploy pipeline.

The database, FaunaDB, is in the same vein of technology: it bills itself as a "data platform built for your cloud".
A key feature is that you can run it "serverless" -- of course, everyone knows there are servers involved somewhere, you just
don't have to manage them. The real advantage is the lack of maintenance and [pay-per-usage pricing](https://fauna.com/pricing).
They also advertise [global](https://fauna.com/serverless-cloud) distribution, a difficult feat for databases that
could bring great performance gains (more on that later).

One important point: Netlify, Netlify Functions, and Fauna all include a free pricing tier.

## Digging in to React

The React application is obviously the biggest part of [in-b4.com](https://in-b4.com), and I learned quite a bit while
building it.

I used [`create-react-app`](https://facebook.github.io/create-react-app/) to get started quickly.

In my opinion the most important and most impressive thing about React is the ecosystem. I knew it was massive going in,
but it's so enormous that for any one piece or concept, there are probably at least three implementations of it that you
can start using with a simple `npm install`. For example, if you needed a date and time picker, you could use
[`react-datepicker`](https://reactdatepicker.com/), [`react-datetime-picker`](https://github.com/wojtekmaj/react-datetime-picker),
[`material-ui-pickers`](https://material-ui-pickers.dev/), or the one in [`react-widgets`](https://jquense.github.io/react-widgets/api/DateTimePicker/)
(which I ended up using). That's a lot of options. Granted some concepts lend themselves better to this than others --
date and time pickers are common -- but nonetheless it's impressive.

Other thoughts on React, in no particular order:

* The component system/approach is intuitive and enables easy re-use of code. Compared to other tools
React makes it very easy to build or download a component and get it working in your application.
* It's obviously mature. You may expect that from something popular released five years ago, but reading the documentation
and working with the API makes it apparent that a lot of thought and care has gone into it. Documentation is
plentiful and descriptive; the API is straightforward and useful. I never found myself confused or unable to do
something. For example, I was pleasantly surprised at how simple it was to handle dynamic changes for values
that are used in various places:
    ```
    this.setState({example: "newvalue"});
    ```
    It's satisfyingly uncomplicated.
* As with all programming, there are many ways to do something in React. When looking for guidance or answers on
how to accomplish something you may find some answers that do things differently than you have so far in
your project. Watch for that to maintain correctness and consistency. For example, you will encounter examples
that render things directly, like this snippet from [`material-ui-pickers`](https://material-ui-pickers.dev/getting-started/installation):
    ``` 
    ReactDOM.render(<App />, document.querySelector('#app'));
    ```
    While the rest of the code in the snippet may be what you're looking for, this line is included for
    demonstration. It would be easy to copy-paste the code provided and have it sort of work, only to end
    up spending a long while debugging it. That's a simple example but you get the idea.
* Most documentation assumes you're familiar with HTML, CSS, and JS. (I say this as someone who is familiar,
so maybe my perception is skewed.) This is a perfectly fair assumption considering the purpose of React, but
anyone thinking they can jump in to web development by going straight to React might struggle to get
their bearings.
* Continuing that point, React has to work within the constraints of JavaScript -- it can't magically fix
the pitfalls surrouding `this`, variable scope, `Promise` flows, etc. For example, this is totally
necessary but I still find it funny:
    ```
    class Example extends React.Component {
        constructor(props) {
            super(props);
            this.handleOnClick = this.handleOnClick.bind(this);
        }

        handleOnClick(event) {
            // Do something.
        }

        render() {
            return (
                <button type="button" onClick={this.handleOnClick}>
                    Click here
                </button>
            )
        }
    }
    ```
* This was the first time I had worked with a single page app (via `create-react-app`) and
I found it a little strange. While it eliminates the need to reload anything during navigation,
that's only significant when compared to an application using server-side rendering. There are tons of
frameworks and tools that allow you to cache the majority of assets on a CDN and populate dynamic data
or fields with an asynchronous request; the no-reload advantage is somewhat nullified when the pages of
a multi-page app are readily and quickly available. I can tell SPAs are great for certain scenarios but I
wouldn't consider it as a default approach.
* I used [`styled-components`](https://www.styled-components.com/) for CSS and thought it was great. I've
never liked the rigamarole of mapping identifiers and classes to their styles, so I found the CSS-in-JS
approach to be a major improvement. That said, it does carry some extra considerations, especially
surrounding security; see [this post on CSS-in-JS security](https://frontarm.com/james-k-nelson/how-can-i-use-css-in-js-securely/)
from James K Nelson at Frontend Armory.

Overall I found React easy to work with. As long as you're familiar with basic web technologies
like HTML, CSS, and JS it's pretty simple to pick up React.

## The REST endpoints

The second portion of the app is the REST API layer. This is extremely simple, comprised of only a read
and write function written in JavaScript. My goal was mainly to try out [Netlify Functions](https://www.netlify.com/docs/functions/)
to see how well it works, and generally I like it. It's a very simple way to add some backend code to a project.
You don't have to bother with an AWS account, IAM roles, API Gateway, etc. You just write your code, configure
`netlify.toml` to account for it, and deploy. That's great for a small project.

There's only one real downside: all functions are deployed to AWS us-east-1 by default. This isn't necessarily *bad*, though
us-east-1 has had its troubles. More importantly, it doesn't really match up with the rest of Netlify's
platform. One of Netlify's best features is its global distribution, minimizing latency for users
all over the world. With functions only served from a single region that distribution improvement
is lost. (More on distribution later.) I don't really fault Netlify for this because it's a difficult problem and
Netlify Functions isn't meant to be an all-encompassing solution.

At the moment Netlify only supports JS and Go functions, but I'm willing to bet that list will grow.

## The database: Fauna

For the database I used [FaunaDB](https://fauna.com/). (Note: a database expert I am not.) Fauna is somewhat
comparable to [Google Spanner](https://cloud.google.com/spanner/), though the pricing model is very different;
Fauna charges per transaction while Spanner is per node/hour. Both are fully managed relational databases
built for cloud applications and with scalability in mind.

As I mentioned earlier, what most interested me about Fauna was the worldwide distribution (again, more on this in a bit).
Fauna advertises their data replication to -- at the time of writing -- four data centers, in the US (3) and Europe (1). At
least 5 more are planned as well, in more parts of the globe. While that first piqued my interest because it's a hard problem
to solve for databases, it also seemed like it would work well with lots of applications -- not necessarily as the main data store,
but for pieces.

Many applications/services need fast reads and fast-enough writes globally for certain things. Going by Fauna's own numbers
they can achieve reads in 1-10ms, and writes in 100-150ms, *with global consistency*. It's not light-speed like some
in-memory stores but that's great (or seems that way to me) for things where you have lots of people submitting data that's
quickly read by people elsewhere in the world. As an imperfect example, posting a Tweet about a developing news story
should happen quickly and needs to be visible to everyone else very quickly -- Fauna seems like it could be good for situations
like that.

To provide some data of my own, the submission function that writes to the database takes about 1.3 seconds for the first write
in a while (I would assume this is an AWS Lambda cold start) but is more like 300ms on average. That's being run from Oregon
and runs the REST layer in us-east-1, so there is some latency and processing involved. The read function in the same scenario
takes about 140ms.

The other interesting thing is the security model: you can provision and distribute keys to clients, which can be used
in the browser's JavaScript. I did not use this because I needed to read and manipulate the data before passing it on
to the client; Fauna may be able to handle this with user-defined functions but I didn't investigate that too much.

Overall Fauna was a breeze to set up and use. They publish a [driver for JavaScript](https://github.com/fauna/faunadb-js)
(and many other languages) that's easy to work with. Creating an account, setting up, and using a database is simple and
free. I haven't encountered any problems using it, but I am also not pushing its limits whatsoever. The only things I've noticed
is the relative lack of analytics. Considering the free tier, ease of setup, and ease of use, I'll probably use Fauna as the
initial database for new projects, and analyze the database choice when it becomes more important.

# Global distribution

Now to finally get around to the topic I keep mentioning: global distribution.

Two of the services used here, Netlify and FaunaDB, distribute your files/code/data worldwide. With those two, the application
and its data are available in many geographical areas, if not globally. However, the REST layer, provided by Netlify Functions,
is only available in the Eastern US by default. Obviously that leads to a performance oddity: loading the application is quite quick,
but running database operations incurs some latency.

For future investigation, I plan to look at [Lambda@Edge](https://aws.amazon.com/lambda/edge/), [Zeit Now](https://zeit.co/now), and/or [Cloudflare Workers](https://www.cloudflare.com/products/cloudflare-workers/). All of these services allow you to run code on CDN edge servers, which could move the REST API from
a single location to many. Cloudflare Workers is interesting because it's familiar to me (I use it at work and personally)
and because of the cache API they provide, which should decrease the number of database requests required. Zeit is also intriguing
because they provide both static site hosting and function deployment -- and they have a free tier.

From what I've learned here this stack has interesting performance potential:

1. Static assets/application on Netlify (Akamai)
2. REST layer on CF Workers, with caching
3. Data on FaunaDB

Alternatively, Zeit may make this even simpler:

1. Static assets/application on Zeit (AWS?)
2. REST layer on Zeit, with caching
3. Data on FaunaDB

I'd like to explore that sometime in the coming months.

# Summary

Some closing notes:

* If you know HTML, CSS, and JS, React is easy to pick up
* React really is as powerful as everyone says
* Netlify Functions work well and are simple to set up, but may not be suitable for more complex use cases
* FaunaDB is easy to set up and work with, and I was impressed by the performance

You can check out the application I built here: https://in-b4.com/

The code is available here: https://github.com/edaemon/in-b4/

Thanks for reading.