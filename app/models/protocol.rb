class Protocol < ActiveRecord::Base
  include Tire::Model::Search
  include Tire::Model::Callbacks

  def self.search(params)
    tire.search(load: true, page: params[:page], per_page: 10) do
      query { string params[:query]} if params[:query].present?
    end
  end
end
