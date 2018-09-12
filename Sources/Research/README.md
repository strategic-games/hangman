# Research
In fact, the reason for writing this whole package was simulating board games and study the game behavior in experimental context. This experimental process could be described step by step:

* Find questions and behavioral hypothesis about the game. Keep in mind that the findings should be useful for future empirical research on the topic.
* Create an experimental design, which variables should be manipulated, how many games, etc.
* measure: Simulate the games according to the design and store the result data somewhere.
* Analyze: Explore the data and (maybe) answer the hypothesis.
* Discuss: Implications, alternative explications, relevance, further questions …

This seems trivial but can easily become messy because the situation of data creation is different from empirical psychological research. There, there is a limit in data quantity, because appropriate subjects have to be recruited, and measuring takes time and organizational overhead. Experiments are often designed to answer more than one question for efficiency. So, one or a few measurements are generated. For software simulations, the only limit is your computing power. It is tempting to create numerous datasets with varying settings, and losing track of the data and their origin. But I would see this paradigma of creating many special datasets as an opportunity and take this advantage. To make this process as comprehensible as possible, some criteria must be met:

[x] Output data must always be bundled with the experimental settings.
[x] The data must provide enough meta information about the software setup which produced the data.
* Data need context and therefore must be documented (naming, timestamps, tagging).

The point of this module is to automate the experimental process as far as viable. It provides a command line tool which reads experimental settings from an input text file, runs the simulations, and archives the results with meta data and settings as JSON file. This file could be read in R and a dynamic report generation tool like [knitr](https://yihui.name/knitr/) or [rmarkdown](https://rmarkdown.rstudio.com) can be used to write the analysis report.

# Todo
* Include build numbering via git
