class CommentsController < ApplicationController
  before_filter :problem_from_id
  before_filter :solution_from_id

  # POST /problems/:problem_id/comments
  def create
    if user_signed_in?
      @comment = Comment.new(params[:comment])
      @comment.user_id = current_user.id
      @comment.user_display_name = current_user.display_name
      if @solution
        @comment.solution = @solution
      else
        @comment.problem = @problem
      end

      respond_to do |format|
        if @comment.save
          format.json { render json: @comment, status: :created, location: @problem }
          format.html { redirect_to problem_path(@problem, anchor: "comment-#{@comment.id}") }
        else
          @comment.problem = nil

          format.json { render json: @comment.errors, status: :unprocessable_entity }
          format.html do
            flash.now[:error] = "Sorry, problem submitting comment...<ul>#{@comment.errors.full_messages.map {|e| "<li>#{e}</li>" }.join}</ul>".html_safe
            render 'problems/show'
          end
        end
      end
    else
      flash[:error] = "You must sign in to post comments"
      redirect_to @problem
    end
  end

  private
  def problem_from_id
    @problem = Problem.find(params[:problem_id])
  end

  def solution_from_id
    if params[:solution_id]
      @solution = Solution.find(params[:solution_id])
    end
  end
end
