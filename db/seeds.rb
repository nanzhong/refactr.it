# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
#

require 'csv'

=begin
problems_count = 0
puts "Loading SO Problems"
CSV.foreach("#{Rails.root}/db/so_problems.csv", headers: true) do |row|
  problems = Problem.where(source: :stack_overflow, source_id: row['Id'] )
  if problems.empty?
    problem = Problem.new
  else
    problem = problems.first
  end
  problem.title = row['Title']
  problem.body = row['Body'].gsub('<pre><code>', '<pre class="prettyprint linenums"><code>')
  problem.parsed = true
  problem.tags = row['Tags'].gsub(/></, ',').gsub(/<|>/,'').split(',') - ['refactoring']
  problem.source = :stack_overflow
  problem.source_id = row['Id']
  problem.rating = row['Score']
  problem.up_votes = problem.rating
  problem.views = row['ViewCount']
  problem.parsed = true
  problem.created_at = row['CreationDate']

  problem.save

  problems_count += 1
  puts "Processed #{problems_count}" if problems_count % 100 == 0
end
=end

solutions_count = 0
puts "Loading SO Solutions"
CSV.foreach("#{Rails.root}/db/so_solutions.csv", headers: true) do |row|
  solutions = Solution.where(source: :stack_overflow, source_id: row['Id'] )
  if solutions.empty?
    solution = Solution.new
  else
    solution = solutions.first
  end

  problems = Problem.where(source: :stack_overflow, source_id: row['ParentId'] )
  next if problems.empty?

  solution.body = row['Body'].gsub('<pre><code>', '<pre class="prettyprint linenums"><code>')
  solution.parsed = true
  solution.source = :stack_overflow
  solution.source_id = row['Id']
  solution.rating = row['Score']
  solution.up_votes = solution.rating
  solution.parsed = true
  solution.created_at = row['CreationDate']
  solution.problem = problems.first

  solution.save

  solutions_count += 1
  puts "Processed #{solutions_count}" if solutions_count % 100 == 0
end
