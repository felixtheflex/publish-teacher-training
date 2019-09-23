class PagesController < ApplicationController
  skip_before_action :authenticate, only: %i[guidance accessibility]

  def accessibility; end

  def cookies; end

  def terms; end

  def privacy; end

  def guidance; end

  def new_features; end

  def transition_info; end

  def rollover; end

  def accept_terms; end
end
