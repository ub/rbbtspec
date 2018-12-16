require 'bundler/setup'
class Dispatcher
  def initialize(hostname: 'localhost', port: 5672)
    @connection = Bunny.new(hostname: hostname, port: port)
    @connection.start
    @channel = @connection.create_channel
    #THAT's THE point -- different channel for read and publish!!!
    @target_chan = @connection.create_channel
  end
  def redispatch_all(source_queue_name)
    queue = @channel.queue(source_queue_name, durable:true)
    consumer = queue.subscribe(:manual_ack => true) do |di, properties, body|
      puts "HEADERS: #{properties.headers.inspect}"
      target = @target_chan.queue(properties.headers['target'], durable: true)
      target.publish(body)
      @channel.acknowledge(di.delivery_tag)
    end
    while queue.message_count > 0
      puts "message count #{queue.message_count}"
      sleep 0
    end
     consumer.cancel
  end

  def channel_ok?
    @channel.status == :open
  end
  def stop
    @connection.close
  end
end