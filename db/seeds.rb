# frozen_string_literal: true

# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

require 'benchmark'

Dir.glob(File.join(Rails.root.join('db/seeds/*.rb'))) do |file|
  load(file)
end

def seed(name)
  print "#{name}: "
  result = Benchmark.realtime do
    yield
  end
  puts sprintf('%0.3fs', result)
end

def seeds
  separator_line
  result = Benchmark.realtime do
    yield
  end
  separator_line
  puts sprintf('[Total] %0.3fs', result)
end

def separator_line
  puts '-' * 20
end

seeds do
  seed(:user){ user }
  seed(:notice){ notice }
  seed(:item){ item }
end
