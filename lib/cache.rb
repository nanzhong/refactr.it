class Cache

  UP_VOTE = "up_vote"
  DOWN_VOTE = "down_vote"

  def self.voted_on_problem?(user_key, problem)
    begin
      voted = REDIS.get(self.problem_vote_key(user_key, problem))
      voted.blank? ? false : voted
    rescue Redis::CannotConnectError
      logger.warn "Cache: Could not connect to redis"
      false
    end
  end

  def self.vote_on_problem(user_key, problem, vote)
    begin
      REDIS.set(self.problem_vote_key(user_key, problem), vote)
    rescue Redis::CannotConnectError
      logger.warn "Cache: Could not connect to redis"
    end
  end

  def self.voted_on_solution?(user_key, solution)
    begin
      voted = REDIS.get(self.solution_vote_key(user_key, solution))
      voted.blank? ? false : voted
    rescue Redis::CannotConnectError
      logger.warn "Cache: Could not connect to redis"
      false
    end
  end

  def self.vote_on_solution(user_key, solution, vote)
    begin
      REDIS.set(self.solution_vote_key(user_key, solution), vote)
    rescue Redis::CannotConnectError
      logger.warn "Cache: Could not connect to redis"
      false
    end
  end

  def self.problem_vote_key(user_key, problem)
    "v:p:#{problem.id}:u:#{user_key}"
  end

  def self.solution_vote_key(user_key, solution)
    "v:s:#{solution.id}:u:#{user_key}"
  end

end
