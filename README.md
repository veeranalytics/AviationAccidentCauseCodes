# Aviation Accident Cause Codes

The goal is to try to extract the most common causes of planes crashes, by using text analysis on the context lines in 
the dataset. This website shows the actual most common causes since the 1960s.

#### Getting and Cleaning Data

The data can be downloaded from 
https://opendata.socrata.com/Government/Airplane-Crashes-and-Fatalities-Since-1908/q2te-8cvq

The code is developed using R.

The libraries have been used:
* tm
* dplyr
* stringr
* tidyr
* factoextra
* ggplot2
* wordcloud

Performed the following steps to clean data:
* Remove Punctuation
* Convert To Lower Case
* Remove English Stopwords
* Strip Whitespace
* Remove removing generic terms related to airline industry

Converted data into document-terms matrix.

Remove sparse terms from document-terms matrix at 95% threshold.

#### Clustering
Used K-Means Cluster with N = 10 (total number of clusters– 10).

#### Frequency Charts
The word cloud chart shows the most frequent words in corpus.

The second chart shows the top 20 most frequent terms.


