module WatcherGroupsHelper

  # Returns the css class used to identify watch links for a given +object+
  def watcher_group_css(object)
    "#{object.class.to_s.underscore}-#{object.id}-watcher_group"
  end

  # Returns a comma separated list of users watching the given object
  def watcher_groups_list(object)
    remove_allowed = User.current.allowed_to?(:delete_issue_watchers, object.project)

    tags = object.watcher_groups.map do |group|
      s = if User.current.admin?
        link_to group.name, group_path(group)
      else
        h(group.name)
      end
      if remove_allowed
        url = {:controller => 'watcher_groups',
               :action => 'destroy',
               :object_type => object.class.to_s.underscore,
               :object_id => object.id,
               :group_id => group}
        s << ' '.html_safe
        s << link_to(l(:button_delete), url,
                     :remote => true, :method => 'post',
                     :class => "delete icon-only icon-del",
                     :title => l(:button_delete))
      end
      content_tag('li', s, :class => "group-#{group.id}")
    end
    content = safe_join tags
    content_tag('ul', content, class: 'watchers watcher-groups') if content.present?
  end

  def watcher_groups_checkboxes(object, groups, checked=nil)
    safe_join groups.map do |group|

      c = checked.nil? ? object.watched_by_group?(group) : checked
      tag = check_box_tag 'issue[watcher_group_ids][]', group.id, c, :id => nil
      content_tag 'label', "#{tag} #{h(group)}".html_safe,
                  :id => "issue_watcher_group_ids_#{group.id}",
                  :class => "floating"
    end
  end

end
