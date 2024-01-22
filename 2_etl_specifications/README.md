# ETL especifications 


## Building ETL rules

We go through `RabbitInAHat` one filed at the time in the CDM 5.4 tables with https://ohdsi.github.io/CommonDataModel/cdm54.html open. 

In `comments` we write a descriptive logic of how the filed is calculated.There are four possibilities. 

- Generated: filed generated during the ETL process, typically primary keys.
- Calculated: calculated from fields in source tables.  
- Info not available: set NULL, 0, '', according to conventions.  Typically, 0 for _concept_id, NULL for others. 
- Info potentially available: Info may be in the current source data but is not ETL in the current implementation, or info may be in the original register and we request it for next implementation. 


## Documentation 

Documentation uses [Just-the-docs](https://github.com/just-the-docs/just-the-docs). 

A github action builds the documentation when merged to main. 

Before a pull request check the documentation is build correctly. 

### Execute locally 
- Prerequisites : 
  - Install Ruby Gem:  https://jekyllrb.com/docs/installation/
  - Install the jekyll and bundler gems. 
  ```sh
  gem install jekyll bundler
  ```

Run the following command with in the `documentation` folder
```sh
bundle exec jekyll serve
```

Browse to http://localhost:4000 

[source](https://jekyllrb.com/docs/)