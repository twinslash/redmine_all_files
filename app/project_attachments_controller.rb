class ProjectAttachmentsController < ApplicationController
  before_filter :project_by_project_id

  def index
    @attachments = Attachments.attachments_for_project @project.id
  end
end
