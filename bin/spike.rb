#!/usr/bin/env ruby

require "celluloid/io"

require "celluloid/net/imap"

class TestListener
  include Celluloid::IO

  def initialize
    kerblam

    every 1 do 
      # HACK: Without this timer up here, other timers created in
      # other contexts may not fire.  It appears that I've run into a
      # bug in Celluloid::Timers.

      puts "TL tick: #{Kernel.caller.length}"
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
    puts "Attempting to connect to IMAP..."
    task_delegator = lambda do |&block|
      async.delegate_new_task block
    end
    begin
      conn = Celluloid::Net::IMAP.new("localhost", task_delegator, self, ssl: false, port: 5143) do |close_reason|
        puts "Connection dropped!"
        restart_imap
      end
      # TODO: the exception rescue should become IMAP specific
      # (connection error, command errors)
    rescue Celluloid::Net::IMAP::Error => e
      puts "Unable to establish IMAP connection because of #{e}"
      restart_imap
      return
    end

    puts "... Connection open!"

    begin
      puts "Logging in..."
      conn.login("alc@openera.com", "PASSWOID")
      puts "... success!"
      
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
    rescue Exception => e
      puts "Command error (auth?), (restarting): #{e}, #{e.backtrace}"

      # See the HACK block in #receive_response.  The decision to
      # delegate the decision to shutdown the IMAP connection in case
      # of error cannot be delegated until a Celluloid::IO issue is
      # solved.

      # disconnecting WOULD trigger a reconnect for us
      conn.disconnect
    end
  end
 
  def kerblam
    1.times do
      async.attach_to_imap
    end
  end
end

l = TestListener.new

sleep
