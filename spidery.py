from scrapy.selector import HtmlXPathSelector
from scrapy.spider import BaseSpider
from scrapy.http import Request
import sys
# a little bit of hacky way to get the domain var from sh but it works so whatever
DOMAIN =   sys.argv[3]
DOMAIN =  DOMAIN.split('=', 1)[-1]
URL = 'http://%s' %DOMAIN

class MySpider(BaseSpider):
    name = DOMAIN
    allowed_domains = [DOMAIN]
    start_urls = [
        URL
    ]

    def parse(self, response):
        hxs = HtmlXPathSelector(response)
        for url in hxs.select('//a/@href').extract():
            if not ( url.startswith('http://') or url.startswith('https://') ):
                url= URL + url
            print url
            yield Request(url, callback=self.parse)
