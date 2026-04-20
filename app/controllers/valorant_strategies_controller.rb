class ValorantStrategiesController < ApplicationController
  def index
    @strategies = ValorantStrategy.ordered
  end

  def new
    @strategy = ValorantStrategy.new
  end

  def create
    # フォームの5つの個別フィールドをagentsに結合
    if params[:valorant_strategy][:agents].blank?
      agent_values = (0..4).map { |i| params["agents_#{i}"].to_s.strip }.reject(&:empty?)
      params[:valorant_strategy][:agents] = agent_values.join(", ")
    end
    @strategy = ValorantStrategy.new(strategy_params)
    unless @strategy.valid?
      render :new, status: :unprocessable_entity and return
    end

    result = ValorantStrategyService.new(@strategy.map, @strategy.agents).call

    if result
      @strategy.attack_rounds  = result[:attack].to_json
      @strategy.defense_rounds = result[:defense].to_json
      @strategy.save!
      redirect_to valorant_strategy_path(@strategy)
    else
      flash.now[:error] = "AI の応答に失敗しました。もう一度お試しください。"
      render :new, status: :service_unavailable
    end
  end

  def show
    @strategy = ValorantStrategy.find(params[:id])
  end

  def destroy
    strategy = ValorantStrategy.find(params[:id])
    strategy.destroy
    redirect_to valorant_strategies_path, notice: "削除しました"
  end

  private

  def strategy_params
    params.require(:valorant_strategy).permit(:map, :agents)
  end
end
