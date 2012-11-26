class Cache

  UP_VOTE = "up_vote"
  DOWN_VOTE = "down_vote"

  def self.voted_on_problem?(user_key, problem)
    voted = REDIS.get(self.problem_vote_key(user_key, problem))
    voted.blank? ? false : voted
  end

  def self.vote_on_problem(user_key, problem, vote)
    REDIS.set(self.problem_vote_key(user_key, problem), vote)
  end

  def self.voted_on_solution?(user_key, solution)
    voted = REDIS.get(self.solution_vote_key(user_key, solution))
    voted.blank? ? false : voted
  end

  def self.vote_on_solution(user_key, solution, vote)
    REDIS.set(self.solution_vote_key(user_key, solution), vote)
  end

  def self.problem_vote_key(user_key, problem)
    "v:p:#{problem.id}:u:#{user_key}"
  end

  def self.solution_vote_key(user_key, solution)
    "v:s:#{solution.id}:u:#{user_key}"
  end

end
