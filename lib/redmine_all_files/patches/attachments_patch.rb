module RedmineAllFiles
  module Patches
    module AttachmentsPatch
      def self.included(base)
        base.extend ClassMethods
      end

      module ClassMethods
        def search_attachments_for_projects projects, tokens = [], options = {}
          project_ids = projects.map(&:id)
          return [] if options[:scope].blank? || project_ids.blank?
          sql_project_ids = "(#{ project_ids.join(', ') })"

          containers = options[:scope].map { |container| container.singularize.camelize }

          statement = '1=1'
          if tokens.any?
            token_clauses = tokens.map do |token|
              str = "((LOWER(a.filename) LIKE %{token} #{ 'OR LOWER(a.description) LIKE %{token}' unless options[:titles_only] })" % { :token => sanitize("%#{token.downcase}%") }
              options[:scope].each do |option|
                val = option[0]
                case val
                  when 'i' then str += " OR (LOWER(#{val}.subject) LIKE %{token} #{ "OR LOWER(#{val}.description) LIKE %{token}" unless options[:titles_only] })" % { :token => sanitize("%#{token.downcase}%") }
                  when 'n', 'd' then str += " OR (LOWER(#{val}.title) LIKE %{token} #{ "OR LOWER(#{val}.description) LIKE %{token}" unless options[:titles_only] })" % { :token => sanitize("%#{token.downcase}%") }
                  when 'p' then str += " OR (LOWER(#{val}.name) LIKE %{token} OR LOWER(#{val}.identifier) LIKE %{token} #{ "OR LOWER(#{val}.description) LIKE %{token}" unless options[:titles_only] })" % { :token => sanitize("%#{token.downcase}%") }
                  when 'w' then str += " OR (LOWER(#{val}.title) LIKE %{token})" % { :token => sanitize("%#{token.downcase}%") }
                  when 'v' then str += " OR (LOWER(#{val}.name) LIKE %{token} #{ "OR LOWER(#{val}.description) LIKE %{token}" unless options[:titles_only] })" % { :token => sanitize("%#{token.downcase}%") }
                  else
                end

              end
              str += ')'
              str

            end
            statement = token_clauses.join(options[:all_words] ? ' AND ' : ' OR ')
            statement = self.sanitize true if statement.blank?
          end


          find_by_sql <<-SQL
            SELECT d.title AS document_title, i.subject AS issue_subject, t.name AS issue_tracker_name,
                   n.title AS new_title, v.name AS version_name, w.title AS wiki_page_title, ww.project_id AS wiki_project_id,
                   p.name AS attachment_project_name, p.id AS attachment_project_id, a.*
            FROM attachments a

            LEFT JOIN documents d ON d.id = a.container_id AND a.container_type = 'Document'
            LEFT JOIN issues i ON i.id = a.container_id AND a.container_type = 'Issue' LEFT JOIN trackers t ON t.id = i.tracker_id
            LEFT JOIN news n ON n.id = a.container_id AND a.container_type = 'News'
            LEFT JOIN versions v ON v.id = a.container_id AND a.container_type = 'Version'
            LEFT JOIN wiki_pages w ON w.id = a.container_id AND a.container_type = 'WikiPage' LEFT JOIN wikis ww ON ww.id = w.wiki_id
            LEFT JOIN projects p ON p.id = d.project_id OR p.id = i.project_id OR p.id = n.project_id OR p.id = v.project_id OR p.id = ww.project_id OR p.id = a.container_id AND a.container_type = 'Project'


            WHERE (d.project_id IN #{sql_project_ids} OR
                   i.project_id IN #{sql_project_ids} OR
                   n.project_id IN #{sql_project_ids} OR
                   v.project_id IN #{sql_project_ids} OR
                   ww.project_id IN #{sql_project_ids} OR
                   p.id IN #{sql_project_ids}
                  ) AND (
                   #{ statement }
                  ) AND a.container_type IN (#{ containers.map { |c| self.sanitize(c) }.join(', ') })
            ORDER BY a.created_on
          SQL

        end
      end
    end
  end
end

Attachment.send(:include, RedmineAllFiles::Patches::AttachmentsPatch) if Attachment.included_modules.exclude? RedmineAllFiles::Patches::AttachmentsPatch
