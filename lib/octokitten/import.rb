module Octokitten
  # Use the golden-comet-preview API in order to import issues more efficiently
  module Import
    PREVIEW_TYPE = 'application/vnd.github.golden-comet-preview'.freeze

    # Import an issue for a repository
    #
    # @param repo [Integer, String, Repository, Hash] A GitHub repository
    # @param title [String] A descriptive title
    # @param body [String] An optional concise description
    # @param comments [Hash] Comments of the issue
    # @param options [Hash] A customizable set of options.
    # @option options [String] :created_at Date of creation.
    # @option options [Integer] :milestone Milestone number.
    # @option options [String] :assignee User login.
    # @option options [Boolean] :closed true if issue state is closed.
    # @option options [String|Array] :labels Array or list of comma separated Label names.
    # @return [Sawyer::Resource] result, including status
    # @see https://gist.github.com/jonmagic/5282384165e0f86ef105#start-an-issue-import
    #
    # @example
    #   Octokit.import_issue(
    #     'foo/bar',
    #     'Fix README',
    #     'Add new API section',
    #     { body: '+1 I will take care' },
    #     { closed: true }
    #   )
    def import_issue(repo, title, body, comments, options = {})
      options[:labels] =
        case options[:labels]
        when String
          options[:labels].split(',').map(&:strip)
        when Array
          options[:labels]
        else
          []
        end
      parameters = { title: title }
      parameters[:body] = body unless body.nil?
      post "#{Octokit::Repository.path repo}/import/issues",
           issue: options.merge(parameters), comments: comments, accept: PREVIEW_TYPE
    end

    # Check the state of an issue import
    #
    # @param repo [Integer, String, Repository, Hash] A GitHub repository
    # @param id [Integer] Id of the issue import
    # @return [Sawyer::Resource]
    # @see https://gist.github.com/jonmagic/5282384165e0f86ef105#start-an-issue-import
    # @example Check import status of issue import with id 4 from repository 'foo/bar'
    #   result = github.check_issue_status('foo/bar', 4)
    def check_issue_status(repo, id)
      path = "#{Octokit::Repository.path repo}/import/issues/#{id}"

      begin
        result = get path, accept: PREVIEW_TYPE

        case result.status
          when 'pending'
            puts "Issue #{id} pending..."

          when 'imported'
            puts "Issue #{id} imported"

          when 'failed'
            puts "Issue #{id} failed"
            puts "Issue #{id} status: #{result.inspect}"
            puts "Issue #{id} import error: #{get_error_message(result)}"

          else
            #
        end

      rescue Octokit::NotFound
        puts "Issue #{id} status: 404 Not found"
      end

      result
    end

    def get_error_message(result)
      message = ""
      p result

      error_count = result.errors.count
      message << "#{error_count} error#{error_count > 1 ? "s" : ""}:"

      result.errors.each do |error|
        message << " #{error.resource} #{error.code}: #{error.field}=\"#{error.value}\""
      end
    end
  end
end

module Octokit
  class InvalidIssue < ArgumentError; end

  # Import module into Octokit
  class Client
    include Octokitten::Import
  end
end
