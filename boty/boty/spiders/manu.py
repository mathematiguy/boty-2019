# -*- coding: utf-8 -*-
import re
import os
import logging
import scrapy
from scrapy.spiders import XMLFeedSpider

with open('birds.txt', 'r') as f:
    birds = f.read().strip().split("\n")

def extract_xpath(response, xp):
    return response.xpath(xp).extract_first()

class ManuSpider(XMLFeedSpider):
    name = 'manu'
    allowed_domains = ['birdoftheyear.org.nz']
    start_urls = ['http://birdoftheyear.org.nz/{}'.format(bird) for bird in birds]

    def parse(self, response):
        result = {
            'url': response.url,
            'mi_name': extract_xpath(response, '//h1/em[@lang="mi"]/text()'),
            'eng_name': extract_xpath(response, '//h1/em[@lang="en-NZ"]/text()'),
            'status': extract_xpath(response, '//dd/text()'),
            'description': extract_xpath(response, '//div[contains(@class, "bird__body")]/p/span/text()'),
            'image': response.urljoin(extract_xpath(response, '//noscript/picture/img/@src')),
        }
        yield result
