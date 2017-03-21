We are currently few developers actively contributing to the project. Feel free to reach out to us for any help.

## Technology stack

The technology stack used in this framework is described below.

### Bare Essentials

**Git** - You guessed it right, we use git for our code versioning following the [git branching model](http://nvie.com/posts/a-successful-git-branching-model/) suggested by Vincent.

**CoffeeScript** - For cleaner code, we have adopted [CoffeeScript](http://coffeescript.org). Please use the below resources to familiarise yourselves.
  - http://coffeescript.org/ 
  - http://js2coffee.org

**Jade** - For HTML, we use jade templating engine.
  - http://jade-lang.com/
  - http://html2jade.org/

**AngularJS** - JavaScript framework that we employ. Very elegant. [Official website](https://angularjs.org/) has the best documentation.

**[WebPack](https://webpack.github.io/)** - module bundler. 

### Optional

**[D3](http://d3js.org)** - Data driven charts
  
## Commit message format

We loosely follow [AngularJs Commit Message Format](https://github.com/angular/angular.js/blob/master/CONTRIBUTING.md#commit):

First line of the git message has to be in the following format: `<type>(<scope>): <subject>`
* `<type>` here is from [this list](https://github.com/angular/angular.js/blob/master/CONTRIBUTING.md#type)
* `<scope>` is a specific module within SOCRAT you're contributing to, i.e. `Core` or `Charts` or `PowerCalc`
* `<subject>` is a description of the change starting with a verb in imperative form, present tense, not capitalized, without period in the end; when commiting unfinished work (e.g. with known bugs), prepend `<subject>` with `WIP`.

Second line of the message should contain reference to the corresponding issue (if such exists) in format: `SOCR/SOCRAT-issues#<issue>`
* `<issue>` here is a number of issue from SOCR/SOCRAT-issues repository

Example of commit message:

```
fix(AppMainMenu): add missing Login button

SOCR/SOCRAT-issues#1
```

## SOCR Datasets for testing

To be able to use any dataset locally for testing, download CSV file from the provided link and place it under ``_build/datasets/iris.csv``. See SOCR Data desription page for details.

**Iris** - The data set contains 3 classes (Iris types) each containing 50 observations (for a total of 150 observations). One class is linearly separable from the other two, but the latter are difficult to linearly separable from each other. The class of the iris plant may be used as the predicted variable. There are 4 variables which can be used as predictive (explanatory) attributes of the Iris class [1] | [CSV file](http://socr-dev.nursing.umich.edu:3000/datasets/iris.csv) | [SOCR Data description page](http://wiki.socr.umich.edu/index.php/SOCR_Data_052511_IrisSepalPetalClasses)

**Simulated SOCR Knee Pain Centroid Location Data** - This simulated data represents the centroid locations for the hypothetical knee-pain locations for 8666 subjects. The data includes the X and Y coordinates of the centroids and a label for the view (left/right and front/back of the knee) [2] | [CSV file](http://socr-dev.nursing.umich.edu:3000/datasets/knee_pain_data.csv) | [SOCR Data description page](http://wiki.socr.umich.edu/index.php/SOCR_Data_KneePainData_041409)

**Neuroimaging study of 27 Alzheimer's disease (AD) subjects, 35 normal controls (NC), and 42 mild cognitive impairment subjects (MCI)** - This is a large neuroimaging study using automated volumetric data processing to obtain different shape and volume measures of local anatomy [3]. The subject population is derived from the Alzheimer's Disease Neuroimaging Initiative (ADNI) database and includes 27 Alzheimer's disease (AD) subjects, 35 normal controls (NC), and 42 mild cognitive impairment subjects (MCI) | [CSV file](http://socr-dev.nursing.umich.edu:3000/datasets/Global_Cortical_Surface_Curvedness_AD_NC_MCI.csv) | [SOCR Data description page](http://wiki.socr.umich.edu/index.php/SOCR_Data_July2009_ID_NI)

**Neuroimaging study of Prefrontal Cortex Volume across Species** - The prefrontal cortex is the anterior part of the frontal lobes of the brain in front of the premotor areas. Prefrontal cortex includes cytoarchitectonic layer IV and includes three regions: orbitofrontal (OFC), dorsolateral prefrontal cortex (PFC), anterior and ventral cingulate cortex. Human brains are much distinct from the brains of other primates and apes specifically in the prefrontal cortex. These structural differences induce significant functional abilities which may account for the significant associating, planning and strategic thinking in humans, compared to other primates [4] | [CSV file](http://socr-dev.nursing.umich.edu:3000/datasets/Prefrontal_Cortex_Volume_across_Species.csv) | [SOCR Data description page](http://wiki.socr.umich.edu/index.php/SOCR_Data_April2009_ID_NI)

**Turkiye Student Evaluation Dataset** - A study at Gazi University, Ankara, Turkey (Turkiye) collected data consisting of 5,820 evaluation scores provided by Gazi University students. Each record consists of 5 meta-data attributes and 28 course specific questions (Q1-Q28) [1] | [CSV file](http://socr-dev.nursing.umich.edu:3000/datasets/Turkiye_Student_Evaluation_Data_Set.csv) | [SOCR Data description page](http://wiki.socr.umich.edu/index.php/SOCR_TurkiyeStudentEvalData)

**Antarctic Ice Thickness Dataset** - Australian Antarctic Data Centers. Regular measurements of the thickness of the fast ice, and of the snow cover that forms on it, are made through drilled holes at several sites near Mawson, Casey and Davis. Number of data points is 1636. | [CSV file](http://socr-dev.nursing.umich.edu:3000/datasets/Antarctic_Ice_Thickness.csv) | [SOCR Data description page](http://wiki.stat.ucla.edu/socr/index.php/SOCR_Data_Dinov_042108_Antarctic_IceThicknessMawson)

**California Ozone Data** - This dataset includes the ozone levels over 20 geographic locations within the State of California for the period between 1980-2006. | [CSV file](http://socr-dev.nursing.umich.edu:3000/datasets/California_Ozone.csv) | [SOCR Data description page](http://wiki.stat.ucla.edu/socr/index.php/SOCR_Data_121608_OzoneData)

**California Ozone Pollution Data** - This dataset includes the ozone levels within the State of California. It contains data (N=175) about the date of Ozone measurement, site-location identifier, latitude, longitude, and the ozone measure (O3) within the State of California. | [CSV file](http://socr-dev.nursing.umich.edu:3000/datasets/California_Ozone_Pollution.csv) | [SOCR Data description page](http://wiki.stat.ucla.edu/socr/index.php/SOCR_Data_121608_CA_US_OzoneData)

**US Ozone Pollution Data** - This data includes the ozone levels for various locations throughout the US. It contains data (N=175) about the date of Ozone measurement, site-location identifier, latitude, longitude, and the ozone measure (O3) within the United States. | [CSV file](http://socr-dev.nursing.umich.edu:3000/datasets/US_Ozone_Pollution.csv) | [SOCR Data description page](http://wiki.stat.ucla.edu/socr/index.php/SOCR_Data_121608_CA_US_OzoneData)

**Baseball Players Dataset** - Human Height and Weight are mostly hereditable, but lifestyles (e.g., regular strenuous physical exercise), diet, health and environmental factors also play a role in determining individual's physical characteristics. The dataset below contains 1035 records of heights and weights for some current and recent Major League Baseball (MLB) Players. These data were obtained from different resources (e.g., IBM Many Eyes and many other references [5][6]). See also the 25,000 records of adolescent height and weight [7]. | [CSV file](http://socr-dev.nursing.umich.edu:3000/datasets/Baseball_Players.csv) | [SOCR Data description page](http://wiki.socr.umich.edu/index.php/SOCR_Data_MLB_HeightsWeights)

**Countries Rankings Dataset** - These data represent commonly accepted measures for raking Countries on variety of factors which affect the country's internal and external international perception of the country's rank relative the the rest of the World. | [CSV file](http://socr-dev.nursing.umich.edu:3000/datasets/Countries_Rankings.csv) | [SOCR Data description page](http://wiki.socr.umich.edu/index.php/SOCR_Data_2008_World_CountriesRankings)

[1] Lichman, M. (2013). [UCI Machine Learning Repository](http://archive.ics.uci.edu/ml). Irvine, CA: University of California, School of Information and Computer Science.

[2] SOCR Data KneePainData 041409. http://wiki.socr.umich.edu/index.php/SOCR_Data_KneePainData_041409

[3] Dinov ID, Van Horn JD, Lozev KM, Magsipoc R, Petrosyan P, Liu Z, MacKenzie-Graha A, Eggert P, Parker DS and Toga AW (2009) Efficient, Distributed and Interactive Neuroimaging Data Analysis using the LONI Pipeline. Front. Neuroinform. (2009) 3:22. [doi:10.3389/neuro.11.022.2009](https://doi.org/10.3389/neuro.11.022.2009), published online: 20 July 2009.

[4] Schoenemann, PT., Sheehan, MJ., Glotzer, DL. (2005) Prefrontal white matter volume is disproportionately larger in humans than in other primates. Nature Neuroscience, 8, 242–252. [doi:10.1038/nn1394](https://doi.org/10.1038/nn1394)

[5] Jarron M. Saint Onge, Patrick M. Krueger, Richard G. Rogers. (2008) Historical trends in height, weight, and body mass: Data from U.S. Major League Baseball players, 1869-1983, Economics & Human Biology, Volume 6, Issue 3, Symposium on the Economics of Obesity, December 2008, Pages 482-488, ISSN 1570-677X, DOI: 10.1016/j.ehb.2008.06.008.

[6] Jarron M. Saint Onge, Richard G. Rogers, Patrick M. Krueger. (2008) Major League Baseball Players' Life Expectancies, Southwestern Social Science Association, Volume 89, Issue 3, pages 817–830, DOI: 10.1111/j.1540-6237.2008.00562.x.

[7] 25,000 records of adolescent height and weight. http://wiki.socr.umich.edu/index.php/SOCR_Data_Dinov_020108_HeightsWeights
