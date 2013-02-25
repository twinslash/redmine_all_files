class AllAttachmentsController < ApplicationController
  Attachment.find_by_sql(<<-SQL
    SELECT d.`project_id`, d.`title`, d.`description`, ww.`project_id`, w.`title`, a.*
    FROM `attachments` a
    LEFT JOIN `documents` d ON d.`id` = a.`container_id` AND a.`container_type` = 'Document'
    LEFT JOIN `wiki_pages` w ON w.`id` = a.`container_id` AND a.`container_type` = 'WikiPage'
    LEFT JOIN `wikis` ww ON ww.`id` = w.`wiki_id`
    LEFT JOIN `projects` p ON p.`id` = a.`container_id` AND a.`container_type` = 'Project'
    WHERE d.`project_id` = 6 OR ww.`project_id` = 6 OR p.`id` = 6
    ORDER BY a.`created_on`
    LIMIT 50
  SQL
  )
end
