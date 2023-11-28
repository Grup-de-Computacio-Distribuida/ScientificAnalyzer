import json
import requests as requests
from DataCollector.Miners.Miner import Miner


class IEEEMiner(Miner):
    def __init__(self, term, start_year, end_year, path):
        super().__init__(term, start_year, end_year, path)
        self.ieee_base_url = "https://ieeexplore.ieee.org"
        self.iee_web_url = self.ieee_base_url + "/search/searchresult.jsp?queryText={term}&highlight=true&returnFacets=ALL&returnType=SEARCH&matchPubs=true&ranges={year}_{year}_Year"
        self.ieee_api_url = self.ieee_base_url + "/rest/search"
        self.token = None
        self.token = self._get_token()
        self._term_no_filter = term

    def _get_editorial(self, paper=None):
        return "IEEE"

    def _get_request_header(self):
        headers = {
            'content-type': "application/json",
            'accept': "application/json",
            'accept-encoding': "gzip, deflate, br",
            'user-agent': "Magic Browser"
        }
        if self.token:
            headers['Cookie'] = 'ERIGHTS=' + self.token
        return headers

    def _get_token(self):
        r = requests.get(self.iee_web_url.format(term=self.term, year=self.start_year),
                         headers=self._get_request_header())
        return r.cookies['ERIGHTS']

    def _get_ieee_post_data(self, page, year):
        return {
            "highlight": True,
            "matchPubs": True,
            "queryText": self._term_no_filter,
            "returnFacets": ["ALL"],
            "returnType": "SEARCH",
            "pageNumber": str(page),
            "ranges": ["{}_{}_Year".format(year, year)]
        }

    def _get_limit(self, year):
        response = requests.post(self.ieee_api_url, json=self._get_ieee_post_data(0, year),
                                 headers=self._get_request_header())
        o_json = json.loads(response.text)
        return o_json['totalPages']

    def _get_current_increase(self):
        return 1

    def _get_list_current_list_of_papers(self, year, current):
        response = requests.post(self.ieee_api_url, json=self._get_ieee_post_data(current, year),
                                 headers=self._get_request_header())
        try:
            o_json = json.loads(response.text)
            if 'records' in o_json:
                return o_json['records']
        except Exception as e:
            print("Error detected on response: " + str(response))
            print(str(e))
        return []

    def _get_content_title(self, paper):
        return paper["articleTitle"]

    def _get_content_citations(self, paper):
        return paper["citationCount"]

    def _get_content_authors(self, paper):
        authors = ""
        if 'authors' in paper:
            authors = "".join(a['preferredName'] + ", " for a in paper['authors'])[:-2]
        return authors
