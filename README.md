# Contents
Mainly a python scraper that collects data from JeffSackmann's repository `https://github.com/JeffSackmann/tennis_atp`, which also cleans and formats the data for other uses.
## Utils
- `utils_scrape.py` contains relevant functions to parse data information, such as calculating tiebreak information, and does some minor cleaning to filter out outliers and nonsensical results
- `utils_clean.py` contains relevant functions to clean and calculating auxilary information such as total minutes played, and spots outlier based on calculations, such as matches that are too short to be feasible.

## Scrapers
The `.ipynb` notebooks titled `scraper`+`x` executes above functions in a notebook in order to convert condense and output a suitable `.csv` file in category `x`.
For example `scraper_singles.ipynb` parses all relevant singles data and compiles it into the `atp_matches.csv` file.
