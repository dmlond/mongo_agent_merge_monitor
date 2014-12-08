mongo_agent_merge_monitor
=========================

extends [dmlond/bwa_samtools_base](https://github.com/dmlond/bwa_samtools_base) with a Ruby script that monitors MongoAgent::Agent alignment_agent tasks in the queue to determine when to create a new merge_bam_agent task.
