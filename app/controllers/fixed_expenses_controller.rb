class FixedExpensesController < ApplicationController
  def index
    @fixed_expenses = FixedExpense.order(:created_at)
    @new_expense = FixedExpense.new
  end

  def create
    @fixed_expense = FixedExpense.new(fixed_expense_params)
    if @fixed_expense.save
      redirect_to fixed_expenses_path, notice: "追加しました"
    else
      @fixed_expenses = FixedExpense.order(:created_at)
      @new_expense = @fixed_expense
      render :index, status: :unprocessable_entity
    end
  end

  def update
    @fixed_expense = FixedExpense.find(params[:id])
    if @fixed_expense.update(fixed_expense_params)
      redirect_to fixed_expenses_path, notice: "更新しました"
    else
      redirect_to fixed_expenses_path, alert: "更新に失敗しました"
    end
  end

  def destroy
    FixedExpense.find(params[:id]).destroy
    redirect_to fixed_expenses_path, notice: "削除しました"
  end

  private

  def fixed_expense_params
    params.require(:fixed_expense).permit(:name, :amount)
  end
end
