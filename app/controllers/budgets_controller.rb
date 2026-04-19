class BudgetsController < ApplicationController
  def index
    @year  = (params[:year]  || Date.today.year).to_i
    @month = (params[:month] || Date.today.month).to_i
    @budget = MonthlyBudget.find_or_create_by(year: @year, month: @month)
    @fixed_expenses = FixedExpense.order(:created_at)
    @fixed_total = @fixed_expenses.sum(:amount)
    @prev = Date.new(@year, @month, 1) << 1
    @next = Date.new(@year, @month, 1) >> 1
  end

  def update
    @budget = MonthlyBudget.find(params[:id])
    if @budget.update(budget_params)
      redirect_to budgets_path(year: @budget.year, month: @budget.month), notice: "保存しました"
    else
      redirect_to budgets_path(year: @budget.year, month: @budget.month), alert: "保存に失敗しました"
    end
  end

  private

  def budget_params
    params.require(:monthly_budget).permit(:electricity, :gas, :water, :phone, :internet)
  end
end
