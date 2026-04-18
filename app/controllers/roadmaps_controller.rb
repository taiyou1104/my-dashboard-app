class RoadmapsController < ApplicationController
  before_action :require_profile

  def index
    @roadmaps = Roadmap.order(
      Arel.sql("CASE WHEN status = 'completed' THEN 1 ELSE 0 END, updated_at DESC")
    )
  end

  def new
    @roadmap = Roadmap.new
  end

  def create
    @roadmap = Roadmap.new(roadmap_params)

    if @roadmap.save
      profile = Profile.first
      generator = RoadmapGenerator.new(profile, @roadmap)
      result = generator.generate

      if result
        updates = { title: result[:title] }
        updates[:duration_days] = result[:duration_days] if result[:duration_days].present?
        @roadmap.update(updates)
        result[:tasks].each do |task_data|
          @roadmap.tasks.create!(
            day_number: task_data["day"],
            title: task_data["title"],
            description: task_data["description"]
          )
        end
        redirect_to @roadmap, notice: "ロードマップを作成しました"
      else
        @roadmap.destroy
        flash.now[:error] = "AIによるタスク生成に失敗しました。もう一度お試しください。"
        render :new, status: :unprocessable_entity
      end
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @roadmap = Roadmap.find(params[:id])
    @tasks = @roadmap.tasks.ordered
  end

  def destroy
    @roadmap = Roadmap.find(params[:id])
    @roadmap.destroy
    redirect_to roadmaps_path, notice: "ロードマップを削除しました"
  end

  private

  def require_profile
    redirect_to edit_profile_path, notice: "まず技術・資格情報を入力してください" unless Profile.exists?
  end

  def roadmap_params
    params.require(:roadmap).permit(:study_content, :purpose, :duration_days, :daily_hours)
  end
end
