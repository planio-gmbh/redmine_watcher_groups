require 'redmine'
require 'watcher_groups/views_issues_hook'


Rails.configuration.to_prepare do

  WatcherGroups::IssuePatch.apply
  IssuesController.send :helper, WatcherGroupsHelper

end

Redmine::Plugin.register :redmine_watcher_groups do
  name 'Redmine Watcher Groups plugin'
  author 'Yasuhiro Kobayashi (original by Kamen Ferdinandov)'
  description 'This is a plugin for Redmine to add wathcer groups functionality'
  version '1.0.1'
  url 'https://github.com/ppyv/redmine_watcher_groups'
end


