class ProjectAttachmentsController < ApplicationController
  before_filter :find_project_by_project_id

  def index
    @all_attachments = Attachment.attachments_for_project @project.id
    @limit = per_page_option
    @attachments_count = @all_attachments.count
    @attachments_pages = Paginator.new self, @attachments_count, @limit, params[:page]
    @offset = @attachments_pages.current.offset
    @attachments = @all_attachments[@offset..(@offset + @limit - 1)]
  end
end
