module WatcherGroups
  module IssuePatch

    def self.apply
      Issue.prepend self unless Issue < self
    end

    def notified_watchers
      notified = super

      watcher_groups.each do |p|
          group_users = p.users.active.to_a
          group_users.reject!{ |user|
            user.mail.blank? || user.mail_notification == 'none'
          }
          if respond_to?(:visible?)
            group_users.reject! {|user| !visible?(user)}
          end
          notified += group_users
      end

      notified.uniq
    end

    def watcher_groups
      principal_ids = Watcher.
        where(watchable_type: 'Issue', watchable_id: id).
        pluck(:user_id)
      Group.where(id: principal_ids)
    end

    # Returns an array of users that are proposed as watchers
    def addable_watcher_groups
      project.principals.select{|p| p.type == 'Group'}.sort - watcher_groups
    end

    # Adds group as a watcher
    def add_watcher_group(group)
      if Watcher.where(watchable_type:'Issue',
                       watchable_id: id,
                       user_id: group.id).none?
        # insert directly into table to avoid user type checking
        Watcher.connection.execute("INSERT INTO `#{Watcher.table_name}` (`user_id`, `watchable_id`, `watchable_type`) VALUES (#{group.id}, #{self.id}, '#{self.class.name}')")
      end
    end

    # Removes user from the watchers list
    def remove_watcher_group(group)
      return nil unless group && group.is_a?(Group)
      Watcher.delete_all "watchable_type = '#{self.class}' AND watchable_id = #{self.id} AND user_id = #{group.id}"
    end

    # Adds/removes watcher
    def set_watcher_group(group, watching=true)
      watching ? add_watcher_group(group) : remove_watcher_group(group)
    end

    # Returns true if object is watched by +user+
    def watched_by_group?(group)
      !!(group && self.watcher_groups.detect {|gr| gr.id == group.id })
    end
  end
end
