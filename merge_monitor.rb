#!/usr/local/bin/ruby

require 'mongo_agent'

agent = MongoAgent::Agent.new({name: 'alignment_agent', queue: ENV['QUEUE']})
while true do
  $stderr.puts "CHECKING"
  agent.get_tasks({
    agent_name: agent.name,
    complete: true,
    error_encountered: false
  }).each do |alignment_task|
    merge_task = agent.get_tasks({agent_name: 'merge_bam_agent', parent_id: alignment_task[:_id]}).first
    # if the merge_task is not nil, then there is a merge either running, or complete, and there is nothing
    # more to do for this alignment
    if merge_task.nil?
      # the merge has not been submitted yet. Either split or align_subset agents are still running.
      completed_split_task = agent.get_tasks({
          agent_name: 'split_agent',
          parent_id: alignment_task[:_id],
          complete: true,
          error_encountered: false
      }).first

      # if the split task is still running, or it ended in error, complete_split_task will be nil
      # either way there is nothing more to do for this alignment task
      unless completed_split_task.nil?
        subsets_aligned = agent.get_tasks({
          agent_name: 'align_subset_agent',
          parent_id: alignment_task[:_id],
          complete: true,
          error_encountered: false
        }).count

        # it is possible that all align_subsets are still running, or one ore more have ended
        # in error, in which case this count will be 0.  Either way, there is nothing more
        # to do for this alignment task
        if completed_split_task[:files].length == subsets_aligned
          agent.db[agent.queue].insert({
            build: alignment_task[:build],
            reference: alignment_task[:reference],
            raw_file: alignment_task[:raw_file],
            subset_bams: completed_split_task[:files].collect{|fd| "#{ fd[:name] }.bam" },
            parent_id: alignment_task[:_id],
            agent_name: 'merge_bam_agent',
            ready: true
          })
        end
      end
    end
  end
  sleep 30
end
