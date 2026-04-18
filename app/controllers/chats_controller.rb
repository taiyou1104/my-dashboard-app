class ChatsController < ApplicationController
  def create
    @roadmap = Roadmap.find(params[:roadmap_id])
    messages = params.require(:messages).map { |m| { role: m[:role], content: m[:content] } }
    task     = params[:task_id].present? ? @roadmap.tasks.find_by(id: params[:task_id]) : nil

    reply = ChatService.new(@roadmap, task, messages).call

    if reply
      render json: { message: reply }
    else
      render json: { error: "AIの応答に失敗しました。もう一度お試しください。" }, status: :service_unavailable
    end
  end
end
