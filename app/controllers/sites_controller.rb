class SitesController < ApplicationController
  before_action :set_site, only: [:show, :edit, :update, :destroy]

  # GET /sites
  # GET /sites.json
  def index
    respond_to do |format|
      format.html do 
        @sites = Site.all
      end
      format.json do
        render json: Site.all
      end
    end
  end

  # GET /sites/1
  # GET /sites/1.json
  def show
    respond_to do |format|
      format.html do 
        set_site
        @site
      end
      format.json do
        render json: @site
      end
    end
  end

  # GET /sites/new
  def new
    @site = Site.new
  end

  # GET /sites/1/edit
  def edit
  end

  # POST /sites
  # POST /sites.json
  def create
    @site = Site.new
    @site.mode = :off
    @site.status = :off
    respond_to do |format|
      if @site.update(params)
        format.html { redirect_to @site, notice: 'Site was successfully created.' }
        format.json { render json: @site }
      else
        format.html { render :new }
        format.json { render json: @site.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /sites/1
  # PATCH/PUT /sites/1.json
  def update
    
    respond_to do |format|
      if @site.update(params)
        format.html { redirect_to @site, notice: 'Site was successfully updated.' }
        format.json { render json: { result: :ok, notice: 'changes saved succesfully', site: @site } }
      else
        format.html { render :edit }
        format.json { render json: @site.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /sites/1
  # DELETE /sites/1.json
  def destroy
    @site.destroy
    respond_to do |format|
      format.html { redirect_to sites_url, notice: 'Site was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_site
      @site = Site.find(params[:id])
    end
end
