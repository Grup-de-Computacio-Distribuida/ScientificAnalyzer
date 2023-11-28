from time import sleep

import bs4
import requests

from DataCollector.Miners.Miner import Miner
from DataCollector.InvalidData import InvalidData

class OpenalexMiner(Miner):
    def __init__(self, term, start_year, end_year, path):
        super().__init__(term, start_year, end_year, path)

        self.reg_for_page = 25
        self.alex_base_url = "https://api.openalex.org/works"
        self.alexa_base_plus_filters = self.alex_base_url + "?filter=default.search:{term},publication_year:{year},primary_location.is_published:true,type:article"
        self.alex_web_url = self.alexa_base_plus_filters + "&select=publication_year,display_name,authorships,primary_location,cited_by_count" #&page={}
    
    def _get_editorial(self, paper=None):
        default = "OPENALEXA"
        if paper:
            editorial = paper['primary_location']['source']['display_name'] if paper['primary_location']['source']else ''
            return editorial if editorial else default
        return default

    def _get_request_header(self):
        headers = {'Content-Type': 'application/json'}
        return headers


    def _find_alex_pages(self, parse):
        if parse:
            count = int(parse['meta']['count'])
            return int(count/self.reg_for_page) + 1 if count != 0 else 0
        return 0


    def _get_limit(self, year):
        url = self.alex_web_url.format(page=0, term=self.term, year=year)
        r = requests.get(url, headers=self._get_request_header())
        return self._find_alex_pages(r.json())

    def _get_current_increase(self):
        return 1

    def _get_list_current_list_of_papers(self, year, current):
        url = self.alex_web_url.format(page=current, term=self.term, year=year)
        r = requests.get(url + '&page={}'.format(current+1), headers=self._get_request_header())
        sleep(2)  # Sleep 1s to avoid ip block
        if 'results' in r.json():
            result = r.json()['results']
            return result if result else []
        return []

    def _get_content_title(self, paper):
        return paper['display_name']

    def _get_content_citations(self, paper):
        return paper['cited_by_count']

    def _get_content_authors(self, paper):
        authors = ""
        if paper['authorships']:  # It is possible n authors defined
            for author in paper['authorships']:
                authors += author['author']['display_name'] + ", "
            authors = authors[:-2]
        authors = authors if authors is None else authors.replace('"', "'")
        return authors
