require 'manual_dispatch'

SOURCE_QUEUE_NAME = 'TEST:RBBTSPEC:SOURCE'
TARGET_QUEUE1_NAME = 'TEST:RBBTSPEC:TARGET1'
TARGET_QUEUE2_NAME = 'TEST:RBBTSPEC:TARGET2'
describe Dispatcher do
  describe '#initialize' do
    it 'creates an instance' do
      expect(subject).to be_a Dispatcher
    end
    it 'has an open channel' do
      expect(subject.channel_ok?).to eq true
    end
  end
  describe '#redispatch_all' do
    let( :source_name) {SOURCE_QUEUE_NAME}
    let(:tgt1) {TARGET_QUEUE1_NAME}
    let(:tgt2) {TARGET_QUEUE2_NAME}
    context 'no source' do
      before(:context) do
        clean_queues
      end

      it 'throws no exceptions' do
        expect {subject.redispatch_all(source_name)}.not_to raise_error
      end
      it 'channel remains open' do
        subject.redispatch_all(source_name)
        expect(subject.channel_ok?).to eq true
      end
    end
    context 'empty source' do
      before(:example) do
        chan.queue(source_name, durable: true)
      end
      it 'throws no exception' do
        expect {subject.redispatch_all(source_name)}.not_to raise_error
      end
    end

    context 'source with 1 compliant message (destination tgt1)' do
      let(:target_queue) {chan.queue(tgt1, durable:true)}
      before(:example) do
        puts "CHANNEL ID= #{chan.id}"
        @source_queue = chan.queue(source_name, durable: true)
        @source_queue.publish(quote_1, :headers =>{'target' => tgt1 })
        chan.confirm_select
        puts "STATUS:#{chan.status}"
        chan.wait_for_confirms
        puts "STATUS:#{chan.status}, COUNT: #{@source_queue.message_count} UNCONFIRMED: #{chan.unconfirmed_set.size}"
        puts "well"

      end
      after(:example) do
        clean_queues
      end


      it 'makes queue empty' do
        puts @source_queue.message_count
        expect{
           subject.redispatch_all(source_name)
        }.to change { @source_queue.message_count }.from(1).to(0)
      end

      it 'republishes a message to target queue' do
        expect{
          subject.redispatch_all(source_name)
        }.to change { target_queue.message_count }.from(0).to(1)

      end


    end
    context 'source with 2 compliant messages (destination tgt1)' do
      before(:example) do
        @source_queue = chan.queue(source_name, durable: true)
        @source_queue.publish(quote_1, :headers =>{'target' => tgt1 })
        @source_queue.publish(quote_2, :headers =>{'target' => tgt1 })
        chan.confirm_select
        chan.wait_for_confirms
      end
      after(:example) do
        clean_queues
      end

      it 'makes queue empty' do
        puts @source_queue.message_count
        expect{
           subject.redispatch_all(source_name)
        }.to change { @source_queue.message_count }.from(2).to(0)
      end


    end
    context 'source with 2 compliant messages  with two targets' do
      before(:example) do
        @source_queue = chan.queue(source_name, durable: true)
        @source_queue.publish(quote_1, :headers =>{'target' => tgt1 })
        @source_queue.publish(quote_2, :headers =>{'target' => tgt2 })
        chan.confirm_select
        chan.wait_for_confirms
      end
      after(:example) do
        clean_queues
      end

      it 'makes queue empty' do
        puts @source_queue.message_count
        expect{
           subject.redispatch_all(source_name)
        }.to change { @source_queue.message_count }.from(2).to(0)
      end
    end
    context 'source with 4 compliant messages  with two targets' do
      let(:target_queue1) {chan.queue(tgt1, durable:true)}
      let(:target_queue2) {chan.queue(tgt2, durable:true)}

      before(:example) do
        @source_queue = chan.queue(source_name, durable: true)
        @source_queue.publish(quote_1, :headers =>{'target' => tgt1 })
        @source_queue.publish(quote_2, :headers =>{'target' => tgt2 })
        @source_queue.publish(quote_3, :headers =>{'target' => tgt1 })
        @source_queue.publish(quote_4, :headers =>{'target' => tgt2 })
        chan.confirm_select
        chan.wait_for_confirms
      end
      after(:example) do
        clean_queues
      end

      it 'makes queue empty' do
        puts @source_queue.message_count
        expect{
           subject.redispatch_all(source_name)
        }.to change { @source_queue.message_count }.from(4).to(0)
      end

      it 'republishes two messages to target queue1' do
        subject.redispatch_all(source_name)
        expect( target_queue1.message_count ).to eq 2
      end
      it 'republishes two messages to target queue2' do

        subject.redispatch_all(source_name)
        expect( target_queue2.message_count ).to eq 2
      end

    end
    xcontext 'source with message without target' do

    end

  end
end