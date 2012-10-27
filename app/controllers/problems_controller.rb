class ProblemsController < ApplicationController

  before_filter :problem_from_id, except: [ :index, :create, :new, :tags, :search ]

  # GET /problems
  def index
    @tags = (params[:tags] || "").split(',')
    @page = (params[:page] || 1).to_i

    @sort = case (params[:order] || "").downcase
      when "rating" then :rating
      when "views"  then :views
      when "date"   then :created_at
      else               :rating
    end

    @problems =
      if params[:q]
        Problem.search do |search|
          search.query do |query|
            query.string params[:q]
          end

          search.sort do |sort|
            sort.by @sort, 'desc'
          end

          unless @tags.empty?
            search.filter(:terms, tags: @tags)
          end

          per_page = Kaminari.config.default_per_page
          search.from((@page - 1) * per_page)
          search.size(per_page)
        end
      else
        @problems =
          if @tags.blank?
            Problem.desc(@sort).page(@page)
          else
            Problem.in(tags: @tags).desc(@sort).page(@page)
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
    @problem.inc(:up_votes, 1)
    @problem.inc(:rating, 1)
    render 'vote'
  end

  # PUT /problems/:id/down_vote
  def down_vote
    @problem.inc(:down_votes, 1)
    @problem.inc(:rating, -1)
    render 'vote'
  end

  private
  def problem_from_id
    @problem = Problem.find(params[:id])
  end

end
