class AiSpecialtiesController < ApplicationController
  def index
    @specialties = AiSpecialty.ordered
  end

  def show
    @specialty = AiSpecialty.find(params[:id])
  end
end
