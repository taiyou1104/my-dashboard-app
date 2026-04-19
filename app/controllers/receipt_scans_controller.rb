class ReceiptScansController < ApplicationController
  def create
    @budget = MonthlyBudget.find(params[:budget_id])

    unless params[:receipt_image].present?
      redirect_to budgets_path(year: @budget.year, month: @budget.month), alert: "画像を選択してください"
      return
    end

    unless ENV["ANTHROPIC_API_KEY"].present?
      redirect_to budgets_path(year: @budget.year, month: @budget.month), alert: "ANTHROPIC_API_KEY が設定されていません"
      return
    end

    file       = params[:receipt_image]
    image_data = Base64.strict_encode64(file.read)
    media_type = file.content_type

    @items = ReceiptScanner.new(image_data, media_type).call

    if @items.nil? || @items.empty?
      redirect_to budgets_path(year: @budget.year, month: @budget.month), alert: "レシートを読み取れませんでした。画像を確認して再試行してください。"
      return
    end

    render :confirm
  end
end
