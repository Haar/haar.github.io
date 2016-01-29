task :deploy do
  puts 'Removing existing build folder'
  `rm -rf build`
  puts 'Building and deploying site to master'
  `mgd --branch master`
  `git checkout source`
end
