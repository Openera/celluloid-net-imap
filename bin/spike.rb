#!/usr/bin/env ruby

require "celluloid/io"

require "celluloid/net/imap"

puts "weenis"

class TestListener
  include Celluloid::IO

  def initialize
#    async.attach_to_imap
    kerblam
  end

  # start this inside a Task.

  # it's a method because that's the only entry point we can use for
  # an async task
  def listen_to_imap(conn)
    conn.task_worker
  end

  def attach_to_imap
    puts "STARTING"
    conn = Celluloid::Net::IMAP.new("localhost", ssl: false)
    async.listen_to_imap conn
    puts "LISTENER KICKED OFF"
    puts conn.capability.inspect
    conn.login("orospakr", "PASSWOID")
    puts conn.select('INBOX')
    email_uids = conn.search(["NOT", "DELETED"])

    puts "You have #{email_uids.length} messages in your INBOX."

    # # conn.idle do |idle_msg|
    # #   puts idle_msg.inspect
    # # end

    # puts "Idling!"
  end

  def kerblam
    50.times do
      async.attach_to_imap
    end
  end
end

l = TestListener.new

sleep
