module RedmineAllFiles
  Rails.configuration.to_prepare do
    require_dependency 'redmine_all_files/patches/attachments_patch'
  end
end
