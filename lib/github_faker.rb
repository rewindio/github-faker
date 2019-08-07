require 'time'
require 'faker'
require 'octokit'
require 'dotenv'
require_relative 'octokitten/import'
Dotenv.load

module GithubFaker
  extend self

  # Create repository fixtures
  #
  # @param quantity [Integer] Number of repositories to create
  # @return [Array] Names of the created repositories
  def create_repositories(quantity)
    names = []
    quantity.times do
      name = create_repository
      redo if names.include? name
    end

    names
  end

  # Create repository fixture
  #
  # @return [String] Name of the created repository
  def create_repository
    name = repository_name
    begin
      options = { description: repository_description, auto_init: true }
      options[:organization] = github_target_user if organization?

      github.create_repository(name, options)
    rescue Octokit::UnprocessableEntity
      # probably, the repository name was already used
    end

    name
  end

  # Create fake issue in repository
  def create_issues(repository, quantity)
    quantity.times do
      create_issue(repository)
    end
  end

  # Create fake issue in repository
  def create_issue(repository)
    repository_fullname = "#{github_target_user}/#{repository}"

    options = {}
    #options[:assignee] = github_target_user if [true, false].sample
    options[:closed] = [true, false].sample
    options[:created_at] = timestamp
    options[:labels] = labels

    comments = []
    for i in 0..1 + rand(15)
      comments[i] = { created_at: timestamp, body: comment }
    end

    result = github.import_issue(repository_fullname, issue_title, issue_body, comments, options)

    while result.status == 'pending' do
      result = github.check_issue_status(repository_fullname, result.id)
      if result.status == 'error'
        raise Octokit::InvalidIssue.new(Octokit.last_response)
      end
    end
  end

  private

  def github
    Octokit::Client.new(access_token: access_token)
  end

  def access_token
    ENV['GITHUB_TOKEN']
  end

  def github_target_user
    ENV['GITHUB_TARGET_USER']
  end

  def organization?
    github_target_user && github.user(github_target_user)[:type] == 'Organization'
  end

  def repository_description
    [Faker::Hacker.adjective, Faker::Hacker.noun, 'to', Faker::Hacker.verb, 'the', Faker::Hacker.adjective, Faker::Hacker.abbreviation].join(' ')
  end

  def repository_name
    [Faker::Hacker.adjective, Faker::Hacker.noun].join('-').gsub(/[^-a-zA-Z0-9]/, '-')
  end

  def issue_title
    [Faker::Hacker.adjective, Faker::Hacker.abbreviation, Faker::Hacker.noun, Faker::Hacker.verb].join(' ')
  end

  def timestamp
    DateTime.parse(Faker::Date.backward(days: 1 + rand(365)).to_s).iso8601
  end

  def issue_body
    Faker::Hacker.say_something_smart
  end
  alias comment issue_body

  def labels
    Array.new(1 + rand(2)) { Faker::ElectricalComponents.passive }
  end
end
