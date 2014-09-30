class CommentsController < ActionController::Base
  def create
    @person = Person.find(params[:person_id])
    @comment = @person.comments.build
    @comment.content = params[:comment][:content]
    @comment.user = current_user.email
    @comment.save
    redirect_to @person
  end


 def destroy
    @person = Person.find(params[:person_id])
    @comment = @person.comments.find(params[:id])
    @comment.destroy
    redirect_to @person
  end
end
