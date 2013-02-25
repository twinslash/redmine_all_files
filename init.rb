require 'redmine_all_files'

Redmine::Plugin.register :redmine_all_files do
  name 'Redmine All Files plugin'
  author 'Dmitry Kovalenok'
  description 'Plugin for Redmine to view all attachments related to current project'
  version '0.0.1'
  url 'https://github.com/twinslash/redmine_all_files'
  author_url 'https://github.com/twinslash'

  project_module :all_files do
    permission 'view_all_files', all_files: :index
  end
end
