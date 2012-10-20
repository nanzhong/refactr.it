class ProblemsController < ApplicationController

  before_filter :problem_from_id, only: [ :show, :edit, :update, :destroy ]

  # GET /groups
  def index
    @problems = Problem::Submission.all

    respond_to do |format|
      format.json { render json: @problems }
      format.html
    end
  end

  # GET /groups/:id
  def show
    respond_to do |format|
      format.json { render json: @problem }
      format.html
    end
  end

  # GET /groups/new
  def new
    @problem = Problem::Submission.new
    @revision = Problem::Revision.new
    @problem.revisions << @revision

    respond_to do |format|
      format.json { render json: @problem }
      format.html
    end
  end

  # POST /groups
  def create
    problem = params['problem']
    files = {}
    problem['files'].each do |file|
      files[file['name']] = { content: file['content'] }
    end

    data = { description: problem['title'],
             public: true,
             files: files }

    puts "*"*100
    puts data.inspect

    @problem = Problem.create_on_github(data)
    puts @problem.errors.inspect

    respond_to do |format|
      if @problem.save
        format.json { render json: @problem, status: :created, location: @problem }
        format.html { redirect_to @problem, notice: 'Problem was successfully posted' }
      else
        format.json { render json: @problem.errors, status: :unprocessable_entity }
        format.html { render action: 'new', warn: 'Error posting problem' }
      end
    end
  end

  # GET /groups/:id/edit
  def edit

  end

  # PUT /groups/:id
  def update

  end

  # DELETE /groups/:id
  def destroy

  end

  private
  def problem_from_id
    @problem = Problem::Submission.find(params[:id])
  end

end
