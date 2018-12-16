require 'bunny'
module BunnyHelper
  SOURCE_QUEUE_NAME = 'TEST:RBBTSPEC:SOURCE'
  TARGET_QUEUE1_NAME = 'TEST:RBBTSPEC:TARGET1'
  TARGET_QUEUE2_NAME = 'TEST:RBBTSPEC:TARGET2'

  def chan
    @connection ||= Bunny.new.start
    @channel ||= @connection.create_channel
  end
  def close_bunny
    @connection&.close
    @connection = @channel= nil
  end

  def clean_queues
    [SOURCE_QUEUE_NAME,
    TARGET_QUEUE1_NAME,
    TARGET_QUEUE2_NAME].each do |qname|
      begin
        chan.queue_delete qname
      rescue Bunny::NotFound => e
        puts "Queue #{qname} not found"
        e.channel_close
        @channel = @connection.create_channel
      end
    end
  end

  #QUOTES stolen from faker
  def quote_1
    "There are some things you can't share without ending up liking each other, and knocking out a twelve-foot mountain troll is one of them."
  end
  def quote_2
    "Words are in my not-so-humble opinion, the most inexhaustible form of magic we have, capable both of inflicting injury and remedying it."
  end
  def quote_3
    "You sort of start thinking anything’s possible if you’ve got enough nerve."
  end
  def quote_4
    "It is our choices, Harry, that show what we truly are, far more than our abilities."
  end

end