from utils_scrape import *
import os
import pandas as pd
import numpy as np
from collections import defaultdict
import datetime

data_dir = "data"
repo = "https://github.com/JeffSackmann/tennis_atp"
master = "JeffSackmann/tennis_atp/blob/master"
prefix = "https://raw.githubusercontent.com"





files = parser_csv(repo)
files_links = [os.path.join(master,i) for i in files]

match_files=[i for i in files if 'matches' in i]
ranking_files=[i for i in files if 'rankings' in i]

match_links=[i for i in files_links if 'matches' in i]
ranking_links=[i for i in files_links if 'rankings' in i]
player_links=[i for i in files_links if i not in match_links+ranking_links]