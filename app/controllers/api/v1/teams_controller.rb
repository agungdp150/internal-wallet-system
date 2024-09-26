# frozen_string_literal: true

class Api::V1::TeamsController < ApplicationController
  def index
    teams = Team.includes(:wallet).all

    render json: { count: teams.count, data: teams }, status: :ok
  end

  def show
    team = Team.includes(:wallet).by_id(params[:id]).first

    if team
      render json: { data: team }, status: :ok
    else
      render json: { error: 'Team not found' }, status: :not_found
    end
  end

  def create
    result = Accounts::Actions::CreateTeam.new.call(args: { team: team_params })

    if result[:success]
      render json: { data: { team: result[:team], wallet: result[:wallet] } }, status: :created
    else
      render json: format_error(result[:error], result[:messages]), status: :unprocessable_entity
    end
  end

  def update
    team = Team.by_id(params[:id]).first

    if team&.update(team_params)
      render json: { data: team }, status: :ok
    else
      render json: format_error('Update failed', team&.errors&.full_messages), status: :unprocessable_entity
    end
  end

  def destroy
    team = Team.by_id(params[:id]).first

    if team&.destroy
      render json: { data: team }, status: :ok
    else
      render json: format_error('Delete failed', team&.errors&.full_messages), status: :unprocessable_entity
    end
  end

  private

  def team_params
    params.require(:team).permit(%i[username name password])
  end

  def format_error(error_message, messages)
    {
      error: error_message,
      messages: messages || ['An unexpected error occurred']
    }
  end
end
