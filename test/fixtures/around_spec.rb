require 'rspec'

RSpec.describe 'TestAround' do
  around do |runner|
    puts 'Before'
    runner.run
    puts 'End'
  end

  it 'shows around messages' do
    puts 'Inside runner message'
  end
end
