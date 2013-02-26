require 'redmine_all_files'
require 'redmine/i18n'

Redmine::Plugin.register :redmine_all_files do
  name 'Redmine All Files plugin'
  author 'Dmitry Kovalenok'
  description 'Plugin for Redmine to view all attachments related to current project'
  version '0.0.1'
  url 'https://github.com/twinslash/redmine_all_files'
  author_url 'https://github.com/twinslash'

  project_module :all_files do
    permission :all_files, { :project_attachments => [:index] }, :public => true
  end
  menu :project_menu, :polls, { :controller => 'project_attachments', :action => 'index' }, caption: ->(project) { I18n.t('all_files') }, after: :files, param: :project_id

end
