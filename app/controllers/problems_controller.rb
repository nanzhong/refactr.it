class ProblemsController < ApplicationController

  before_filter :problem_from_id, except: [ :index, :create, :new, :tags ]

  # GET /problems
  def index
    @sort = case (params[:order] || "").downcase
      when "rating" then :rating
      when "views"  then :views
      when "date"   then :created_at
      else               :rating
    end

    @problems = Problem.desc(@sort)

    respond_to do |format|
      format.json { render json: @problems }
      format.html
    end
  end

  # GET /problems/:id
  def show
    @problem.inc(:views, 1)

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

  end

  # PUT /problems/:id
  def update
    respond_to do |format|
      if @problem.update_attributes(params[:problem])
        format.html { redirect_to @problem, notice: 'Problem was successfully updated.' }
        format.json { head :no_content }
      else
        format.json { render json: @problem.errors, status: :unprocessable_entity }
        format.html do
          flash.now[:error] = "Sorry, problem submitting problem...<ul>#{@problem.errors.full_messages.map {|e| "<li>#{e}</li>" }.join}</ul>".html_safe
          render action: 'new', error: @problem.errors.full_messages 
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
    @problem.inc(:up_vote, 1)
    @problem.inc(:rating, 1)
    render 'vote'
  end

  # PUT /problems/:id/down_vote
  def down_vote
    @problem.inc(:down_vote, 1)
    @problem.inc(:rating, -1)
    render 'vote'
  end

  private
  def problem_from_id
    @problem = Problem.find(params[:id])
  end

end
