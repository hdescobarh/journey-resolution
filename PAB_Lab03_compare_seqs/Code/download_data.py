# python3
# author: hdescobarh

import warnings

import requests as rq


# https://www.ncbi.nlm.nih.gov/books/NBK25500/
class Eutility:
    def __init__(self):
        self.base_url = "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/"
        self.esearch_url = self.base_url + "esearch.fcgi"
        self.efetch_url = self.base_url + "efetch.fcgi"
        self.info_url = self.base_url + "einfo.fcgi"

    def info(self, db=None):
        response = rq.get(self.info_url, params={"retmode": "JSON", "db": db})
        return response.json()

    # https://www.ncbi.nlm.nih.gov/books/NBK25499/#chapter4.ESearch
    def search(self, db: str, term: str, **kwargs):
        # validations
        if kwargs.get("retmode") is not None:
            warnings.warn("retmode argument will be ignored", RuntimeWarning)

        # make HTTP request
        kwargs.update({"db": db, "term": term, "retmode": "JSON"})
        response = rq.get(self.esearch_url, params=kwargs)
        return response.json()

    # https://www.ncbi.nlm.nih.gov/books/NBK25499/#chapter4.EFetch
    def fetch(
        self,
        db: str,
        uid_list: list[str] | str,
        rettype="fasta",
        retmode="text",
        **kwargs
    ):

        # "For sequence databases (nuccore, popset, protein),
        # the UID list may be a mixed list of GI numbers and accession.version identifiers."

        # valid rettype and retmode:
        # https://www.ncbi.nlm.nih.gov/books/NBK25499/table/chapter4.T._valid_values_of__retmode_and/?report=objectonly

        if uid_list is list:
            identifiers = ",".join(uid_list)
        else:
            identifiers = uid_list

        kwargs.update(
            {
                "db": db,
                "id": identifiers,
                "rettype": rettype,
                "retmode": retmode,
            }
        )

        return rq.get(self.efetch_url, params=kwargs)


if __name__ == "__main__":
    import csv
    import sys
    from pathlib import Path

    to_download_file = sys.argv[1]
    output_path = Path(sys.argv[2])

    eutility = Eutility()

    with open(to_download_file, newline="", encoding="utf-8") as csvfile:
        # file must contain at least the headers ['id', 'refseq_accession', 'start', 'end']
        reader = csv.DictReader(csvfile)
        for row in reader:
            response = eutility.fetch(
                "nuccore",
                row["refseq_accession"],
                seq_start=row["start"],
                seq_stop=row["end"],
            )

            current_file = output_path / (row["id"] + ".fasta")
            current_file.parent.mkdir(parents=True, exist_ok=True)
            current_file.write_bytes(response.content)
