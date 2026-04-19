class MonthlyExpensesController < ApplicationController
  def create
    @budget = MonthlyBudget.find(params[:budget_id])
    @expense = @budget.monthly_expenses.build(expense_params)
    if @expense.save
      redirect_to budgets_path(year: @budget.year, month: @budget.month)
    else
      redirect_to budgets_path(year: @budget.year, month: @budget.month), alert: "追加に失敗しました"
    end
  end

  def destroy
    @budget = MonthlyBudget.find(params[:budget_id])
    @budget.monthly_expenses.find(params[:id]).destroy
    redirect_to budgets_path(year: @budget.year, month: @budget.month)
  end

  private

  def expense_params
    params.require(:monthly_expense).permit(:name, :amount)
  end
end
