module ProjectAttachmentsHelper

  # Groups attachments by criteria array
  #
  # Suppose we have 5 Attachments:
  # @attachments =
  # [<Attacment#1 id = 1, created_on = 'Project'>,
  #  <Attacment#1 id = 1, container_type = 'WikiPage'>,
  #  <Attacment#3 id = 2, container_type = 'Project'>,
  #  <Attacment#4 id = 1, container_type = 'WikiPage'>]
  # call group_by(@attachments, :id, :container_id) should return
  # {1 => {'Project'  => [<Attacment#1 id = 1, container_type = 'Project'>],
  #        'WikiPage' => [<Attacment#1 id = 1, container_type = 'WikiPage'>, <Attacment#4 id = 1, container_type = 'WikiPage'>]},
  #  2 => {'Project'  => [<Attacment#3 id = 2, container_type = 'Project'>]}}
  def group_by(attachments = [], *criterias)
    return attachments if criterias.empty?
    return [] if attachments.empty?
    criteria = criterias.first
    groups = Hash.new { |h, k| h[k] = [] }
    if criteria.is_a? Proc
      attachments.each do |attachment|
        groups[criteria.call(attachment)] << attachment
      end
    elsif criteria.is_a?(String) || criteria.is_a?(Symbol)
      attachments.each do |attachment|
        groups[attachment.send(criteria)] << attachment
      end
    else
      raise ArgumentError
    end

    groups.each do |categoria, group|
      groups[categoria] = group_by group, *criterias[1..-1]
    end

    groups
  end

  # Returns text for link to container
  #
  # Document: Document: document_title => projects/project_id/documents/id
  # Issue: Issue:issue_tracker_name issue_id. issue_subject => projects/project_id/issues/id
  # New: New: new_title => projects/project_id/news/id
  # File: File: attachment.filename => project/project_id/file/id
  # Version: Version: name => projects/project_id/versions/id
  # Wiki_page: Wiki page: title => projects/project_id/wiki_pages/id
  def link_to_container_for(attachment)
    link = case attachment.container_type
    when 'Issue' then
      "#{t('to_issue')} #{link_to("#{ attachment.issue_tracker_name } #{ attachment.container_id }. #{ attachment.issue_subject }", issue_path(attachment.container_id))}"
    when 'Project' then
      text = params[:project_id].present? ? t('to_project_files') : attachment.project.to_s
      (params[:project_id].present? ? '' : "#{t('to_project_files')} ") + link_to(text, project_files_path(attachment.container_id))
    when 'Version' then
      "#{t('to_version')} #{link_to(attachment.version_name, version_path(attachment.container_id))}"
    when 'WikiPage' then
      "#{t('to_wiki_page')} #{link_to(attachment.wiki_page_title, url_for(:controller => 'wiki', :action => 'show', :project_id => attachment.attachment_project_id,
               :id => Wiki.titleize(attachment.wiki_page_title), :version => nil))}"
    when 'Document' then
      "#{t('to_document')} #{link_to(attachment.document_title, document_path(attachment.container_id))}"
    when 'News' then
      "#{t('to_news')} #{link_to(attachment.new_title, news_path(attachment.container_id))}"
    else
      raise ArgumentError
    end
    project_link = params[:project_id].present? || attachment.container_type.eql?('Project') ? '' : " #{t('of_the_project')} #{link_to attachment.project.to_s, project_path(attachment.attachment_project_id)}"
    "#{t('attached')} #{link}#{project_link}".html_safe
  end

  # Generates a link to download an attachment.
  #
  # Options:
  # * :text - Link text (default to attachment filename)
  def link_to_download(attachment, options={})
    text = options.delete(:text) || attachment.filename
    link_to(text, { :controller => 'attachments', :action => 'download',
            :id => attachment, :filename => attachment.filename },
            options.merge({ :target => '_blank' }))
            #options.merge({ :download => attachment.filename, :target => '_blank' }))
  end

  # Returns array with extensions which have appropriate icons
  def available_icons
    ["aiff", "png", "psd", "ics", "dat", "flv", "tiff", "mp3", "dmg", "avi", "ots", "_page", "html",
     "dxf", "iso", "dotx", "tga", "ott", "sql", "eps", "cpp", "txt", "otp", "xls", "java", "wav", "rb",
     "tgz", "aac", "ppt", "odf", "yml", "mpg", "qt", "bmp", "xlsx", "exe", "jpg", "mid", "pdf", "ai",
     "css", "xml", "hpp", "rtf", "rar", "php", "py", "dwg", "key", "zip", "c", "gif", "odt", "mp4", "h",
     "doc", "ods"]
  end

  # Generates path to thumbnail icon for attachment
  # If attachment is a image returns path to it
  def thumbnail_path_for(attachment, icon_size="512px")
    if attachment.image?
      "/attachments/thumbnail/#{ attachment.id }/#{icon_size.sub("px",'')}"
    elsif (icon = attachment.filename.match(/([^\.]+)$/)[1]).in? available_icons
      File.join('/plugin_assets', 'redmine_all_files', 'images', 'Free-file-icons', icon_size, "#{ icon }.png")
    else
      File.join('/plugin_assets', 'redmine_all_files', 'images', 'Free-file-icons', icon_size, '_blank.png')
    end
  end

end
