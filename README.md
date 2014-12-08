mongo_agent_merge_monitor
=========================

This application uses the [MongoAgent](https://github.com/dmlond/mongo_agent)
api to monitor the subprocesses of alignment_agent tasks to determine
when they have finished, and the subset_bam files are ready to be merged
into a single bam file.  It then submits a task targetted to the merge_bam_agent.

See the [mongo_agent_alignment](https://github.com/dmlond/mongo_agent_alignment)
documentation for more details.
