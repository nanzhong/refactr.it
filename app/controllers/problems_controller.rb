class ProblemsController < ApplicationController

  before_filter :problem_from_id, except: [ :index, :create, :new, :tags, :search ]

  # GET /problems
  def index
    if params[:q] && params[:q].blank?
      flash.now[:error] = "Sorry, you can not search for an empty string. :("
    end

    @query = params[:q]
    @language = params[:lang]
    @tags = (params[:tags] || "").split(',')
    @page = (params[:page] || 1).to_i

    @sort = case (params[:order] || "").downcase
      when "rating" then :rating
      when "views"  then :views
      when "date"   then :created_at
      else               :rating
    end

    @problems =
      unless @query.blank?
        Problem.search do |search|
          search.query do |query|
            query.string @query
          end

          search.sort do |sort|
            sort.by @sort, 'desc'
          end

          unless @tags.empty?
            search.filter(:terms, tags: @tags)
          end

          unless @language.nil?
            search.filter(:term, language: @language)
          end

          per_page = Kaminari.config.default_per_page
          search.from((@page - 1) * per_page)
          search.size(per_page)
        end
      else
        @problems =
          if @tags.blank?
            unless @language.nil?
              Problem.where(language: @language).desc(@sort).page(@page)
            else
              Problem.desc(@sort).page(@page)
            end
          else
            unless @language.nil?
              Problem.in(tags: @tags).where(language: @language).desc(@sort).page(@page)
            else
              Problem.in(tags: @tags).desc(@sort).page(@page)
            end
          end
      end

    respond_to do |format|
      format.json { render json: @problems }
      format.html
    end
  end

  # GET /problems/:id
  def show
    @problem.inc(:views, 1)

    user = user_signed_in? ? current_user.id : request.remote_ip

    @voted = Cache.voted_on_problem?(user, @problem)
    @voted_solutions = {}
    @problem.solutions.each do |solution|
      unless solution.id.blank?
        @voted_solutions[solution.id] = Cache.voted_on_solution?(user, solution)
      end
    end

    respond_to do |format|
      format.json { render json: @problem }
      format.html
    end
  end

  # GET /problems/new
  def new
    @problem = Problem.new

    respond_to do |format|
      format.json { render json: @problem }
      format.html
    end
  end

  # POST /problems
  def create
    @problem = Problem.new(params[:problem])

    @problem.user = current_user if user_signed_in?

    respond_to do |format|
      if @problem.save
        activity_data = {
          'user_id' => @problem.user.nil? ? nil : @problem.user.id,
          'user_name' => @problem.user.nil? ? nil : @problem.user.display_name,
          'problem_id' => @problem.id,
          'problem_title' => @problem.title,
          'problem_language' => @problem.language,
          'problem_formatted_language' => @problem.formatted_language,
          'timestamp' => @problem.created_at.to_formatted_s(:long_ordinal)
        }
        ActivityFeed.add(ActivityFeed::Event::PROBLEM_NEW, activity_data)

        format.json { render json: @problem, status: :created, location: @problem }
        format.html { redirect_to @problem, notice: 'Problem was successfully posted' }
      else
        format.json { render json: @problem.errors, status: :unprocessable_entity }
        format.html do
          flash.now[:error] = "Sorry, problem submitting problem...<ul>#{@problem.errors.full_messages.map {|e| "<li>#{e}</li>" }.join}</ul>".html_safe
          render action: 'new'
        end
      end
    end
  end

  # GET /problems/:id/edit
  def edit
    if user_signed_in? && current_user == @problem.user
      render
    else
      flash[:error] = "You do not have permission to edit this problem."
      redirect_to @problem
    end
  end

  # PUT /problems/:id
  def update
    respond_to do |format|
      if @problem.update_attributes(params[:problem])
        activity_data = {
          'user_id' => @problem.user.id,
          'user_name' => @problem.user.display_name,
          'problem_id' => @problem.id,
          'problem_title' => @problem.title,
          'problem_language' => @problem.language,
          'problem_formatted_language' => @problem.formatted_language,
          'timestamp' => @problem.updated_at.to_formatted_s(:long_ordinal)
        }
        ActivityFeed.add(ActivityFeed::Event::PROBLEM_UPDATE, activity_data)

        format.html { redirect_to @problem, notice: 'Problem was successfully updated.' }
        format.json { head :no_content }
      else
        format.json { render json: @problem.errors, status: :unprocessable_entity }
        format.html do
          flash.now[:error] = "Sorry, problem updating problem...<ul>#{@problem.errors.full_messages.map {|e| "<li>#{e}</li>" }.join}</ul>".html_safe
          render action: 'new'
        end
      end
    end
  end

  # DELETE /problems/:id
  def destroy

  end

  # GET /problems/tags
  def tags
    query_tag = params[:q].strip
    tags = Problem::TAGS.select {|tag| tag =~ /#{query_tag}/}
    tags << query_tag unless tags.include? query_tag
    render json: tags.map {|tag| {id: tag, name: tag} }
  end

  # PUT /problems/:id/up_vote
  def up_vote
    @problem.up_vote

    if user_signed_in?
      Cache.vote_on_problem(current_user.id, @problem, Cache::UP_VOTE)
    else
      Cache.vote_on_problem(request.remote_ip, @problem, Cache::UP_VOTE)
    end

    @vote = Cache::UP_VOTE

    render 'vote'
  end

  # PUT /problems/:id/down_vote
  def down_vote
    @problem.down_vote

    if user_signed_in?
      Cache.vote_on_problem(current_user.id, @problem, Cache::DOWN_VOTE)
    else
      Cache.vote_on_problem(request.remote_ip, @problem, Cache::DOWN_VOTE)
    end

    @vote = Cache::DOWN_VOTE

    render 'vote'
  end

  private
  def problem_from_id
    @problem = Problem.find(params[:id])
  end

end
