require_relative '../github_faker'

namespace :github_faker do
  desc "Create fake repositories"
  task :create_repositories, [:quantity] do |_task, args|
    quantity = args[:quantity] ? Integer(args[:quantity]) : 1
    puts "Adding #{quantity} repositories"

    names = []
    quantity.times do
      name = GithubFaker.create_repository
      redo if names.include? name
      puts "Created repository #{name}"
    end
  end

  desc "Create fake issues"
  task :create_issues, [:repository, :quantity] do |_task, args|
    quantity = args[:quantity] ? Integer(args[:quantity]) : 1
    repository = args[:repository]
    abort 'Requires argument "repository". Usage: rake github_fixtures:create_issues[quantity,repository] # no spaces' unless repository

    puts "Adding #{quantity} issues"

    quantity.times do |number|
       GithubFaker.create_issue(repository)
      puts "Created issue #{number} of #{quantity}"
    end
  end
end
