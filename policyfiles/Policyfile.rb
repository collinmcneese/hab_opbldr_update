# Policyfile.rb - Describe how you want Chef Infra Client to build your system.
#
# For more information on the Policyfile feature, visit
# https://docs.chef.io/policyfile.html

# A name that describes what the system you're building with Chef does.
name 'hab_opbldr_update'

# Where to find external cookbooks:
default_source :chef_repo, '../'

# run_list: chef-client will run these recipes in the order specified.
run_list 'hab_opbldr_update'

# Specify a custom source for a single cookbook:
cookbook 'hab_opbldr_update', path: '../cookbooks/hab_opbldr_update'
cookbook 'test', path: '../test/fixtures/cookbooks/test'

tests = (Dir.entries('./test/fixtures/cookbooks/test/recipes').select { |f| !File.directory? f })
tests.each do |test|
  test = test.gsub('.rb', '')
  named_run_list :"#{test.to_sym}", "test::#{test}"
end