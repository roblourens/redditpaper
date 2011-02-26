import simplejson as json
from urllib import urlopen
import urllib
from os.path import expanduser

def isImage(url):
    if url.lower().endswith('.jpg') or\
       url.lower().endswith('.png') or\
       url.lower().endswith('.gif') or\
       url.lower().endswith('.bmp') or\
       url.lower().endswith('.tif'):
        return True
    else:
        return False

def getImageFromURL(url):
    if isImage(url):
        return url

    # else, parse HTML, find images (later)

redditBaseURL = "http://www.reddit.com"
def getDictFromListing(listing):
    #log(listing)
    imageURL = getImageFromURL(listing['url'])
    submission = redditBaseURL + listing['permalink']
    domain = listing['domain']

    if imageURL != None:
        return {
            'image': imageURL,
            'sub': submission,
            'domain': domain
            }


loginURL = 'http://www.reddit.com/api/login'
wallpapersURL = 'http://www.reddit.com/r/wallpapers/.json?count=%d&after=%s'
outputPath = expanduser('~/html/rp/images.json')
pages = 4
pagesize = 25
images = []
origlistings = [] # the original listing json for selected listings, kept for calculating paging
def getImages():
    for i in range(pages):
        # calculate value for the 'after' parameter
        if (len(origlistings) > 0):
            prevlastfullname = origlistings[-1]['data']['name']
        else:
            prevlastfullname = ''

        # get json wallpaper listings
        content = urlopen(wallpapersURL%(pagesize*i, prevlastfullname)).read()

        # parse json into py objects
        data = json.loads(content)

        # each listing is an entry on the front page of /r/wallpapers, in order
        frontpage = data['data']['children']

        # a list of image listing dicts to be json-ified and output
        for listing in frontpage:
            dict = getDictFromListing(listing['data'])
            if dict != None:
                images.append(dict)
                origlistings.append(listing)

    # put the output into JSON
    output = json.dumps(images)

    # write to file
    f = open(outputPath, 'w')
    f.write(output)
    f.close()
