class BooksController < ApplicationController
  def index
    @books_by_status = Book::STATUSES.keys.index_with do |status|
      Book.where(status: status).ordered
    end
    @new_book = Book.new
  end

  def create
    @book = Book.new(book_params)
    if @book.save
      redirect_to books_path, notice: "「#{@book.title}」を追加しました"
    else
      @books_by_status = Book::STATUSES.keys.index_with { |s| Book.where(status: s).ordered }
      render :index, status: :unprocessable_entity
    end
  end

  def update
    @book = Book.find(params[:id])
    if @book.update(book_params)
      redirect_to books_path, notice: "更新しました"
    else
      redirect_to books_path, alert: "更新に失敗しました"
    end
  end

  def destroy
    book = Book.find(params[:id])
    book.destroy
    redirect_to books_path, notice: "「#{book.title}」を削除しました"
  end

  private

  def book_params
    params.require(:book).permit(:title, :author, :status, :rating, :memo, :started_on, :finished_on)
  end
end
