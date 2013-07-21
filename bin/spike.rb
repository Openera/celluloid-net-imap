#!/usr/bin/env ruby

require "celluloid/io"

require "celluloid/net/imap"

puts "weenis"

class TestListener
  include Celluloid::IO

  def initialize
#    async.attach_to_imap
    kerblam

    every 1 do 
      # HACK: Without this timer up here, other timers created in
      # other contexts may not fire.  It appears that I've run into a
      # bug in Celluloid::Timers.

      # puts "TL tick: #{Kernel.caller.length}"
    end
  end

  # have to use this because Actor#async doesn't accept blocks.
  def delegate_new_task(block)
    block.call
  end

  def restart_imap
    puts "Restarting IMAP in a few seconds..."
    after 3 do
      puts "Re-activating... stack count: #{Kernel.caller.inspect}"
      async.attach_to_imap
    end
  end

  def attach_to_imap
    puts "STARTING"
    task_delegator = lambda do |&block|
      async.delegate_new_task block
    end
    begin
      conn = Celluloid::Net::IMAP.new("localhost", task_delegator, self, ssl: false) do |close_reason|
        puts "Connection dropped!"
        restart_imap
      end
    rescue Exception => e
      puts "Unable to establish IMAP connection because of #{e}"
      restart_imap
      return
    end

    puts "LISTENER KICKED OFF"
    puts conn.capability.inspect
    conn.login("orospakr", "PASSWOID")
    puts conn.select('INBOX')
    # email_uids = conn.search(["NOT", "DELETED"])
    # email_uids.each do |message_id|
    #   puts "wat: #{message_id}"
    #   puts "Envelope: #{(conn.fetch message_id, "ENVELOPE")[0]}"
    #   puts (conn.fetch message_id, "BODYSTRUCTURE")[0].attr["BODYSTRUCTURE"].inspect   
    # end

    # puts "You have #{email_uids.length} messages in your INBOX."

    conn.idle do |idle_msg|
      puts "GOT IDLE MESSAGE: #{idle_msg.inspect}"
    end

    # puts "Idle handler installed."

    # # conn.idle do |idle_msg|
    # #   puts idle_msg.inspect
    # # end

    # puts "Idling!"
  end

      # IDLE lifecycle:

      # 0. Select mailbox

      # Begin listening.  We're doing a naiive best-effort hint of
      # updates, so just whenever we see an EXISTS do an update

      # 1. Check our UID validity (same as synchronous client in our
      #    Rails app does), if different, schedule a backwards (?) update.  When does the IMAP idle start up again?  

      # 1. get max UID of the mailbox (that is our current level; if it's newer than the current max UID

      # 1. wait on IDLE

      # 2. wait for untagged responses (and send those untagged
      #    responses to the callback)

      # 3. when timer goes ding at 29 minutes  

  def kerblam


    1.times do
      async.attach_to_imap
    end
  end
end

l = TestListener.new

sleep
