# Contents
Mainly a python scraper that collects data from Jeff Sackmann's [repository](https://github.com/JeffSackmann/tennis_atp), which also cleans and formats the data for other uses.
Also includes a folder `Rmodel` for work done on tennis modelling in `R` language.
## Utils
- `utils_scrape.py` contains relevant functions to parse data information, such as calculating tiebreak information, and does some minor cleaning to filter out outliers and nonsensical results
- `utils_clean.py` contains relevant functions to clean and calculating auxilary information such as total minutes played, and spots outlier based on calculations, such as matches that are too short to be feasible.

## Scrapers
The `.ipynb` notebooks titled `scraper`+`x` executes above functions in a notebook in order to convert condense and output a suitable `.csv` file in category `x`.
For example `scraper_singles.ipynb` parses all relevant singles data and compiles it into the `atp_matches.csv` file.

## Example Implementations
Examples of computations used on the collected data. Note most of these requires `csv` files that need to be compiled throught the scraper:
- `example.ipynb` shows that the average age of the top 100 male players used to decrease up until the 1980s, yet has been increasing since 1990, perhaps due to increasing medicinal knowledge, technology and the emergence of a few key players.
- `matches_clean.ipynb` conducts analysis on the average playing time per match. Several factors are examined, such as number of sets, surface, tournament size.
- `Logistic.ipynb` fits a simple Bradley-Terry aka logistic model on the data.
