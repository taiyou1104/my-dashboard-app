class AiSpecialtyChatsController < ApplicationController
  def create
    specialty = AiSpecialty.find(params[:ai_specialty_id])
    messages  = params.require(:messages).map do |m|
      { role: m[:role], content: m[:content] }
    end

    # 最初のユーザーメッセージだけプロンプトテンプレートで拡張する
    if messages.length == 1 && messages[0][:role] == "user"
      messages[0] = {
        role: "user",
        content: specialty.build_first_prompt(messages[0][:content])
      }
    end

    reply = AiSpecialtyChat.new(specialty, messages).call

    if reply
      render json: { message: reply }
    else
      render json: { error: "AIの応答に失敗しました。Ollamaが起動しているか確認してください。" },
             status: :service_unavailable
    end
  end
end
