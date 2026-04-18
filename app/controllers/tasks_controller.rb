class TasksController < ApplicationController
  def update
    @task = Task.find(params[:id])
    @task.update(
      completed: !@task.completed,
      completed_at: @task.completed ? nil : Time.current
    )

    roadmap = @task.roadmap
    new_status = roadmap.progress_percentage == 100 ? "completed" : "in_progress"
    roadmap.update(status: new_status)

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to roadmap }
    end
  end
end
