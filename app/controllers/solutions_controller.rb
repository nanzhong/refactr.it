class SolutionsController < ApplicationController
  before_filter :problem_from_id
  before_filter :solution_from_id, only: [ :up_vote, :down_vote, :edit, :update ]

  # POST /problems/:problem_id/solutions
  def create
    @solution = Solution.new(params[:solution])
    @solution.problem = @problem

    if user_signed_in?
      @solution.user = current_user
    end

    respond_to do |format|
      if @solution.save
        format.json { render json: @solution, status: :created, location: @problem }
        format.html { redirect_to problem_path(@problem, anchor: "solution-#{@solution.id}") }
      else
        @solution.problem = nil

        format.json { render json: @solutions.errors, status: :unprocessable_entity }
        format.html do
          flash.now[:error] = "Sorry, problem submitting solution...<ul>#{@solution.errors.full_messages.map {|e| "<li>#{e}</li>" }.join}</ul>".html_safe
          render 'problems/show#form'
        end
      end
    end
  end

  # GET /problems/:problem_id/solutions/:id/edit
  def edit
    if user_signed_in? && current_user == @solution.user
      render
    else
      flash.now[:error] = "You do not have permission to edit this problem."
      redirect_to @problem
    end
  end

  # PUT /problems/:problem_id/solutions/:id
  def update
    respond_to do |format|
      if @solution.update_attributes(params[:solution])
        format.html { redirect_to @problem, notice: 'Solution was successfully updated.' }
        format.json { head :no_content }
      else
        format.json { render json: @solution.errors, status: :unprocessable_entity }
        format.html do
          flash.now[:error] = "Sorry, problem updating solution...<ul>#{@solution.errors.full_messages.map {|e| "<li>#{e}</li>" }.join}</ul>".html_safe
          render action: 'problems/show'
        end
      end
    end
  end

  # PUT /problems/:problem_id/solution/:id/up_vote
  def up_vote
    @solution.inc(:up_votes, 1)
    @solution.inc(:rating, 1)

    if user_signed_in?
      Cache.vote_on_solution(current_user.id, @solution, Cache::UP_VOTE)
    else
      Cache.vote_on_solution(request.remote_ip, @solution, Cache::UP_VOTE)
    end

    @vote = Cache::UP_VOTE

    render 'vote'
  end

  # PUT /problems/:problem_id/solution/:id/down_vote
  def down_vote
    @solution.inc(:down_votes, 1)
    @solution.inc(:rating, -1)

    if user_signed_in?
      Cache.vote_on_solution(current_user.id, @solution, Cache::DOWN_VOTE)
    else
      Cache.vote_on_solution(request.remote_ip, @solution, Cache::DOWN_VOTE)
    end

    @vote = Cache::DOWN_VOTE

    render 'vote'
  end

  private
  def problem_from_id
    @problem = Problem.find(params[:problem_id])
  end

  def solution_from_id
    @solution = Solution.find(params[:id])
  end
end
