# Anti-fake news

Propaganda is blamed for swaying elections in an age of social media.  Fake news is easily spread and amplified by bots, with an aim of getting mainstream media to report upon it, and to force a denial and so be associated with the target, to introduce an element of doubt where there is no real evidence or reason to do so. 

Methods of propaganda can be traced from planning upon anonymous networks such as 4chan and reddit, execution by high frequency twitter bots and prominant opposition figures to doubt being expressed in mainstream media.  A recent example is a [USA alt-right groups campaigning against the French presidential election, #MacronLeaks](https://medium.com/@DFRLab/hashtag-campaign-macronleaks-4a3fb870c4e8).  

A lot of campaigns are only interested in introducing enough doubt that pro-votes don't vote, the problem being that genuine corruption issues and made-up corruption issues can both equally influence people's opinions. 

## Propaganda vs whistle-blowing

Doubt is entertained by a neutral observer since the reputation of sources and accusations are difficult to find before the story is shared, given the high velocity of sharing that occurs.  Quality journalism where sources and facts are checked can be regarded as the same if not less trustworthy than random blogs or news sources only interested in advancing their political aims. As noise increases and news becomes less trustworthy, all news sources start to be treated with suspicion. 

At the same time, the press' role as a check and balance on corruption must be respected, where genuine relevations of corruption in democracy must be allowed to flourish, if factually accurate. 

## Filter bubbles and political polarity

The issue of news sources is further componded by the customisation of social news feeds each user now has, which seems to amplify personal preferences and demonise opposing points of view.  User's follow and unfollow those who agree with their own beliefs so much, that eventually their vision of reality is far removed from those who don't agree.  Traditional political values of cooperation and compromise seem to be eroding: [evidence of this can be seen in US voting patterns](https://www.washingtonpost.com/news/wonk/wp/2015/04/23/a-stunning-visualization-of-our-divided-congress/?utm_term=.2ff4602859bd).

## Reputation of sources and transparency of bias

As a proposed solution to the above, it is suggested that if people could in some way verify the reputation and interest bias of the news source's and resharers they would then be able to make a better judgement on if the news is worth listening too.  Judgements that are easier to make when in person are now lacking via social media

To frame the problem as a data analysis project, this project wishes to achieve the following:

* To give a live relative reputation score of news stories that can be checked before a user reshares a story
* To reveal personal bias' that the news source or resharer may have
* To allow personal preferences of the end user decide how far out of their own 'filter bubble' they want to see

If people want to only accept news from within their bubble, so be it.  But at least with a measure of how trustworthy a news source is within their own bubble, they can make that decision consciously and not be at the mercy of manipulation of news that some bad actors choose to do.

## Execution

For the end user, this could manifest itself like so:

* A user chooses or creates a seed list of trusted news sources. (people, publications)
* Via a browser plugin or extension, users see a score for previous affiliations of the news source or person, how much that entity is usually in agreement with their own views, and how trusted that source is by your own bubble.
* Users can choose to also rate the news they are reading on reputation metrics, to further improve the scores in the future fro both themselves and others. 

e.g.

```
www.alt-right.example/obama-is-a-muslim
source history: obama -100, islam -100, socialism -80, nazis +50, juadism -50
affinity-your-views: -10
bubble-reputation: +20

www.socialism.example/should-religion-be-banned
source histry: socialism +100, nazis -100, juadism -50, islam -20, obama +10
affinity-your-views: +30
bubble-reputation: -50

www.centre-ground.news/did-president-take-a-bribe
source histry: socailism +10, nazis -50, juadism +20, islam +20, obama +50
affinity-your-views: +10
bubble-reputation: +50
```

## Data backend

* Starting with twitter, build up network graph of users and followers
* Per topic pagerank score?
* Analyse texts for entities and their sentiment towards them
* Calculate affinity score of reshares of URLs, hashtags and text entities




