#!/bin/bash

# Runs the monthly build task.  This is a very long-running job that updates MESH stuff.
# According to customization.txt, this should be run after nightly build.

# rake RAILS_ENV=production nightlyBuild >> rake_result.txt

rake RAILS_ENV=production monthlyBuild >> monthly_rake.log
rake RAILS_ENV=production db:vacuum

# Do we need to rebuild the cache here?  Daily task normally does it.
