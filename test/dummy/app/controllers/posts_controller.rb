class PostsController < ApplicationController
  before_action :set_post, only: [:show, :edit, :update, :destroy]

  # GET /posts
  def index
    @posts = Post.all
    @view = view(Post::Show)

    @view.populate(@posts)
  end

  # GET /posts/1
  def show
    @view = view(Post::Show)

    @view.populate(@post)
  end

  # GET /posts/new
  def new
    @post = Post.new
    @form = view(Post::Form)

    @form.populate(@post)
  end

  # GET /posts/1/edit
  def edit
    @form = view(Post::Form)

    @form.populate(@post)
  end

  # POST /posts
  def create
    @post = Post.new
    @form = view(Post::Form)

    @form.populate @post, post_params
    @form.validate
    @form.submit if @form.valid?

    if @form.submitted?
      redirect_to @post
    else
      render :new
    end
  end

  # PATCH/PUT /posts/1
  def update
    @form = view(Post::Form)

    @form.populate @post, post_params
    @form.validate
    @form.submit if @form.valid?

    if @form.submitted?
      redirect_to @post
    else
      render :edit
    end
  end

  # DELETE /posts/1
  def destroy
    @post.destroy
    redirect_to posts_url, notice: 'Post was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_post
      @post = Post.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def post_params
      params.require(:post).permit(:title, :body)
    end
end
