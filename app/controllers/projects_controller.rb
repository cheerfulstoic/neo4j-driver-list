class ProjectsController < ApplicationController
  def index
    fail "Invalid param" if not %w{created_at updated_at pushed_at}.include?(params[:sort_by])

    @projects = Project.all.sort_by do |project|
      project.github_repo_data[params[:sort_by] || 'created_at'] || '999999999'
    end
  end

  private

  def get_url_body(url)
    CACHE.fetch(url) do
      URI.parse(url).open.read
    end
  end

end
