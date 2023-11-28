import urllib
from time import sleep
from DataCollector.InvalidData import InvalidData
import re

class Miner:
    csv_format = "\"{year}\",\"{title}\",\"{citations}\",\"{authors}\",\"{editorial}\""
    csv_headers = "year,title,citations,authors,editorial"

    def __init__(self, term, start_year, end_year, path):
        self.term=urllib.parse.quote(term)
        self.start_year = start_year
        self.end_year = end_year
        self.path = path
        self.safe_term = re.sub(r'[^a-zA-Z0-9_.]', '', self.term)

    def _get_editorial(self, paper=None):  # Return editorial Name
        raise NotImplementedError

    def _get_year_file_name(self, year):

        return self.path + "/tmp_" + self._get_editorial() + "_" + str(year) + '_' + self.safe_term + "_data.csv"

    def _write_csv_header(self, year):
        with open(self._get_year_file_name(year), "w") as f:
            f.write(self.csv_headers + "\n")

    def run(self):
        print()
        print("----------------------")
        print(self._get_editorial())
        print("----------------------")
        total_analyzed = 0
        year = self.start_year
        while year < self.end_year + 1:
            self._write_csv_header(year)
            total_analyzed += self.year_analysis(year)
            year += 1
        print("Total analyzed: " + str(total_analyzed))

    def save_reg(self, year, title, citations, authors, editorial):
        with open(self._get_year_file_name(year), "a") as f:
            title = title if title is None else title.replace('"', "'")
            authors = authors if authors is None else authors.replace('"', "'")
            editorial = editorial if editorial is None else editorial.replace('"', "'")
            f.write(self.csv_format.format(year=year, title=title,
                                           citations=citations,
                                           authors=authors,
                                           editorial=editorial) + "\n")

    def year_analysis(self, year):
        year_analyzed = 0
        current = 0
        print("Start analysis year: " + str(year))
        limit = self._get_limit(year)
        while current < limit:
            print("Year " + str(year) + ": Progress: " + str(round((current / limit) * 100, 2)) + "%")
            try:
                year_analyzed += self.page_analysis(year, current)
            except Exception as e:
                print("ERROR ON GET PAGE: {}".format(str(e)))
                print("WAITING 120s")
                sleep(120)
                print("RETRING...")
                continue
            current += self._get_current_increase()
            print("Current " + str(current) + " Limit:" + str(limit) + " Year analized:" + str(year_analyzed))
        print("Year " + str(year) + ": Progress: 100%, Analyzed: " + str(year_analyzed))
        return year_analyzed

    def page_analysis(self, year, current):  # Analise page documents and return the number of analyzed documents
        analyzed = 0
        papers = self._get_list_current_list_of_papers(year, current)
        for paper in papers:
            try:
                title, citations, authors = self.reg_analysis(paper)
                self.save_reg(year, title, citations, authors, self._get_editorial(paper))
            except InvalidData:
                pass
            analyzed += 1
        return analyzed

    def reg_analysis(self, paper):
        return self._get_content_title(paper), self._get_content_citations(paper), self._get_content_authors(paper)

    def _get_list_current_list_of_papers(self, year, current):
        raise NotImplementedError

    def _get_content_title(self, paper):
        raise NotImplementedError

    def _get_content_citations(self, paper):
        raise NotImplementedError

    def _get_content_authors(self, paper):
        raise NotImplementedError

    def _get_limit(self, year):
        raise NotImplementedError

    def _get_current_increase(self):
        raise NotImplementedError


