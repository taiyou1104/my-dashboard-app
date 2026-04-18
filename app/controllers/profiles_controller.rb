class ProfilesController < ApplicationController
  def show
    @profile = Profile.first
    redirect_to edit_profile_path if @profile.nil?
  end

  def edit
    @profile = Profile.first || Profile.new
  end

  def update
    @profile = Profile.first || Profile.new

    if @profile.update(profile_params)
      redirect_to roadmaps_path, notice: "プロフィールを保存しました"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def profile_params
    params.require(:profile).permit(:skills, :certifications)
  end
end
