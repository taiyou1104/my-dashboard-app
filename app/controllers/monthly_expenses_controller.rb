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

  def batch_create
    @budget = MonthlyBudget.find(params[:budget_id])
    items   = params[:items]&.values || []
    added   = 0

    items.each do |item|
      next unless item[:selected] == "1" && item[:name].present? && item[:amount].to_i > 0
      @budget.monthly_expenses.create!(name: item[:name], amount: item[:amount].to_i)
      added += 1
    end

    redirect_to budgets_path(year: @budget.year, month: @budget.month),
                notice: "#{added}件追加しました"
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
