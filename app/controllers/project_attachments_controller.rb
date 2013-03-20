class ProjectAttachmentsController < ApplicationController
  before_filter :find_project_by_project_id

  helper SearchHelper

  @@module_names_to_container_types = { :issue_tracking => 'issues', :news => 'news', :documents => 'documents', :wiki => 'wiki_pages', :files => 'files' }

  def index
    @question = params[:q] || ""
    @question.strip!
    @all_words = params[:all_words] ? params[:all_words].present? : true
    @titles_only = params[:titles_only] ? params[:titles_only].present? : false

    # extract tokens from the question
    # eg. hello "bye bye" => ["hello", "bye bye"]
    @tokens = @question.scan(%r{((\s|^)"[\s\w]+"(\s|$)|\S+)}).collect {|m| m.first.gsub(%r{(^\s*"\s*|\s*"\s*$)}, '')}
    # tokens must be at least 2 characters long
    @tokens = @tokens.uniq.select {|w| w.length > 1 }
    # no more than 5 tokens to search for
    @tokens.slice! 5..-1 if @tokens.size > 5


    # find enabled project modules
    @enabled_module_names = @project.enabled_modules.map(&:name)
    # find available container types
    @container_types = @@module_names_to_container_types.select { |k, _| @enabled_module_names.include?(k.to_s) }.map { |k, v| v } << 'versions'

    # user select container types from available
    @scope = @container_types.select {|t| params[t]}
    @scope = @container_types if @scope.empty?

    @all_attachments = Attachment.search_attachments_for_project @project.id,
                                                                 @tokens,
                                                                 :scope => @scope,
                                                                 :all_words => @all_words,
                                                                 :titles_only => @titles_only


    @limit = per_page_option
    @attachments_count = @all_attachments.count
    @attachments_pages = Paginator.new self, @attachments_count, @limit, params[:page]
    @offset = @attachments_pages.current.offset
    @attachments = @all_attachments[@offset..(@offset + @limit - 1)]
  end
end
