module RedmineAllFiles
  module Patches
    module AttachmentsPatch
      def self.included(base)
        base.extend ClassMethods
      end

      module ClassMethods
        def attachments_for_project id
          Attachment.find_by_sql <<-SQL
            SELECT d.`title` AS document_title, i.`subject` AS issue_subject, t.`name` AS issue_tracker_name,
            n.`title` AS new_title, v.`name` AS version_name, w.`title` AS wiki_page_title, a.*
            FROM `attachments` a

            LEFT JOIN `documents` d ON d.`id` = a.`container_id` AND a.`container_type` = 'Document'
            LEFT JOIN `issues` i ON i.`id` = a.`container_id` AND a.`container_type` = 'Issue'
            LEFT JOIN `trackers` t ON t.`id` = i.`tracker_id`
            LEFT JOIN `news` n ON n.`id` = a.`container_id` AND a.`container_type` = 'New'
            LEFT JOIN `versions` v ON v.`id` = a.`container_id` AND a.`container_type` = 'Version'
            LEFT JOIN `wiki_pages` w ON w.`id` = a.`container_id` AND a.`container_type` = 'WikiPage'
            LEFT JOIN `wikis` ww ON ww.`id` = w.`wiki_id`


            WHERE d.`project_id` = #{id} OR i.`project_id` = #{id} OR n.`project_id` = #{id} OR a.`container_id` = #{id} AND a.`container_type` = 'Project' OR v.`project_id` = #{id} OR ww.`project_id` = #{id}
            ORDER BY a.`created_on`
            LIMIT 50
          SQL
        end
      end
    end
  end
end

Attachment.send(:include, RedmineAllFiles::Patches::AttachmentsPatch) if Attachment.included_modules.exclude? RedmineAllFiles::Patches::AttachmentsPatch
