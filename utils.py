import urllib.request
import re


def parser_csv(repo,exclude=["atp_matches_doubles_yyyy.csv"]):
    f=urllib.request.urlopen(repo)
    mb=f.read()
    str_rep=mb.decode("utf8")
    f.close()
    files=list(set(re.findall('\\w+?\\.csv',str_rep)))
    return ([i for i in files if i not in exclude])


if __name__ == '__main__':
    print('This file contains utility functions for web-scraping of tennis data, and does nothing when run as a script')
    
    
    
    
    

