class CommentsController < ActionController::Base
  def create
    @commentable = params[:comment][:commentable].constantize.find(params[:comment][:commentable_id])
    @comment = @commentable.comments.build
    @comment.content = params[:comment][:content]
    @comment.user = current_user.email
    @comment.save
    redirect_to @commentable
  end

  def destroy
    @commentable = params[:commentable].constantize.find(params[:commentable_id])
    @comment = @commentable.comments.find(params[:id])
    @comment.destroy
    redirect_to @commentable
  end
end
