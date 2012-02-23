#!/bin/bash

# Run the nightly build task.
# Source: customization.txt

rake RAILS_ENV=production nightlyBuild >> rake.log
rake RAILS_ENV=production db:vacuum

rake tmp:cache:clear 
rake cache:clear
rake RAILS_ENV=production cache:populate taskname=abstracts > cache.log
rake RAILS_ENV=production cache:populate taskname=investigators >> cache.log
rake RAILS_ENV=production cache:populate taskname=orgs >> cache.log
rake RAILS_ENV=production cache:populate taskname=investigator_graphs >> cache.log
rake RAILS_ENV=production cache:populate taskname=org_graphs >> cache.log
rake RAILS_ENV=production cache:populate taskname=investigator_graphviz >> cache.log
rake RAILS_ENV=production cache:populate taskname=org_graphviz >> cache.log
rake RAILS_ENV=production cache:populate taskname=mesh >> cache.log
