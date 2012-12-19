class ActivityFeed

  CHANNEL = 'activity_feed'

  module Event
    PROBLEM_NEW = 'problem_new'
    PROBLEM_UPDATE = 'problem_update'
    SOLUTION_NEW = 'solution_new'
    SOLUTION_UPDATE = 'solution_update'
    COMMENT_NEW = 'comment_new'
  end

  def self.reload
    begin
      REDIS.del 'activity'

      activities = []
      activities += Problem.desc(:created_at).limit(10).to_a
      activities += Solution.desc(:created_at).limit(10).to_a

      # TODO Need someway to incorporate updates in initial reload, currently this breaks because
      #      updating a child also results in the parent to be updated

      # activities += Problem.desc(:updated_at).limit(10).to_a
      # activities += Solution.desc(:updated_at).limit(10).to_a

      activities.uniq!
      activities.sort! do |a,b|
        [a.created_at, a.updated_at].max <=> [b.created_at, b.updated_at].max
      end

      activities.take(10).each do |activity|
        data = {
          'user_id' => activity.user.nil? ? nil : activity.user.id,
          'user_name' => activity.user.nil? ? nil : activity.user.display_name,
        }

        case activity.class
        when Problem
          data.merge!({
            'problem_id' => activity.id,
            'problem_title' => activity.title,
            'problem_language' => activity.language,
            'problem_formatted_language' => activity.formatted_language,
          })

          self.add(Event::PROBLEM_NEW, data.merge('timestamp' => activity.created_at.to_formatted_s(:long_ordinal)))

          # See above TODO
          #if activity.created_at >= activity.updated_at
          #  self.add(Event::PROBLEM_NEW, data.merge('timestamp' => activity.created_at.to_formatted_s(:long_ordinal)))
          #else
          #  self.add(Event::PROBLEM_UPDATE, data.merge('timestamp' => activity.updated_at.to_formatted_s(:long_ordinal)))
          #end
        when Solution
          data.merge!({
            'problem_id' => activity.problem.id,
            'problem_title' => activity.problem.title,
            'problem_language' => activity.problem.language,
            'problem_formatted_language' => activity.problem.formatted_language,
            'solution_id' => activity.id
          })

          self.add(Event::SOLUTION_NEW, data.merge('timestamp' => activity.created_at.to_formatted_s(:long_ordinal)))

          # See above TODO
          #if activity.created_at >= activity.updated_at
          #  self.add(Event::SOLUTION_NEW, data.merge('timestamp' => activity.created_at.to_formatted_s(:long_ordinal)))
          #else
          #  self.add(Event::SOLUTION_UPDATE, data.merge('timestamp' => activity.updated_at.to_formatted_s(:long_ordinal)))
          #end
        end
      end

      return true
    rescue Redis::CannotConnectError
      logger.warn "Cache: Could not connect to redis"
      return false
    end
  end

  def self.all
    begin
      length = REDIS.llen 'activity'
      activities = REDIS.lrange 'activity', 0, length
      return activities.map {|a| JSON.parse(a)}
    rescue Redis::CannotConnectError
      logger.warn "Cache: Could not connect to redis"
      return nil
    end
  end

  def self.get(num)
    begin
      activities = REDIS.lrange 'activity', 0, num
      return activities.map {|a| JSON.parse(a)}
    rescue Redis::CannotConnectError
      logger.warn "Cache: Could not connect to redis"
      return nil
    end
  end

  def self.add(event, data)
    begin
      begin
        REDIS.lpush 'activity', {event: event, data: data}.to_json
      rescue Redis::CannotConnectError
        logger.warn "Cache: Could not connect to redis"
      end

      # TODO Enable live updating via pushes from pusher
      # Pusher.trigger(CHANNEL, event, data)
    rescue Pusher::Error => e
      logger.error "ActivityFeed: Pusher Error, could not add an activity #{e.inspect}"
    end
  end

end
