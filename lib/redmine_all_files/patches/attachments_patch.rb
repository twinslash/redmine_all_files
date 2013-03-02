module RedmineAllFiles
  module Patches
    module AttachmentsPatch
      def self.included(base)
        base.extend ClassMethods
      end

      module ClassMethods
        def search_attachments_for_project id, tokens = [], options = {}
          return [] if options[:scope].blank?

          token_clauses = tokens.map do |token|
            "(LOWER(a.`filename`) LIKE %{token} #{ 'OR LOWER(a.`description`) LIKE %{token}' unless options[:titles_only] })" % { token: sanitize("%#{token.downcase}%") }
          end
          statement = token_clauses.join(options[:all_words] ? ' AND ' : ' OR ')
          statement = self.sanitize true if statement.blank?

          find_by_sql <<-SQL
            SELECT
            #{ "d.`title` AS document_title," if options[:scope].include? 'documents' }
            #{ "i.`subject` AS issue_subject, t.`name` AS issue_tracker_name," if options[:scope].include? 'issues' }
            #{ "n.`title` AS new_title," if options[:scope].include? 'news' }
            #{ "v.`name` AS version_name," if options[:scope].include? 'versions' }
            #{ "w.`title` AS wiki_page_title," if options[:scope].include? 'wiki_pages' }
            a.*

            FROM `attachments` a

            #{ "LEFT JOIN `documents` d ON d.`id` = a.`container_id` AND a.`container_type` = 'Document'" if options[:scope].include? 'documents' }
            #{ "LEFT JOIN `issues` i ON i.`id` = a.`container_id` AND a.`container_type` = 'Issue' LEFT JOIN `trackers` t ON t.`id` = i.`tracker_id`" if options[:scope].include? 'issues' }
            #{ "LEFT JOIN `news` n ON n.`id` = a.`container_id` AND a.`container_type` = 'News'" if options[:scope].include? 'news' }
            #{ "LEFT JOIN `versions` v ON v.`id` = a.`container_id` AND a.`container_type` = 'Version'" if options[:scope].include? 'versions' }
            #{ "LEFT JOIN `wiki_pages` w ON w.`id` = a.`container_id` AND a.`container_type` = 'WikiPage' LEFT JOIN `wikis` ww ON ww.`id` = w.`wiki_id`" if options[:scope].include? 'wiki_pages' }


            WHERE
            (
            #{ "d.`project_id` = #{id} OR" if options[:scope].include? 'documents' }
            #{ "i.`project_id` = #{id} OR" if options[:scope].include? 'issues' }
            #{ "n.`project_id` = #{id} OR" if options[:scope].include? 'news' }
            #{ "v.`project_id` = #{id} OR" if options[:scope].include? 'versions' }
            #{ "ww.`project_id` = #{id} OR" if options[:scope].include? 'wiki_pages' }
            #{ "a.`container_id` = #{id} AND a.`container_type` = 'Project' OR" if options[:scope].include? 'files' }
            #{ self.sanitize false }
            ) AND (
            #{ statement }
            )
            ORDER BY a.`created_on`
          SQL
        end
      end
    end
  end
end

Attachment.send(:include, RedmineAllFiles::Patches::AttachmentsPatch) if Attachment.included_modules.exclude? RedmineAllFiles::Patches::AttachmentsPatch
