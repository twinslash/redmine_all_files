class ProjectAttachmentsController < ApplicationController
  before_filter :find_project_by_project_id

  def index
    @attachments = Attachment.attachments_for_project @project.id
  end
end
