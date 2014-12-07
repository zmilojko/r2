class ScansController < ApplicationController
  before_action :set_site
  before_action :set_scan, only: [:show, :edit, :update, :destroy]

  # GET /scans
  # GET /scans.json
  def index
    if params[:limit]
      recent_scans = @site.scans.where(:last_visited.ne => nil).order(:last_visited).limit(params[limit])
      @scans = recent_scans
    else
      @scans = @site.scans.all
    end
    respond_to do |format|
      format.html do 
        @scans
      end
      format.json do
        render json: @scans
      end
    end
  end
  
  # GET /scans/resport.json
  def report
    unless params[:limit]
      params[:limmit] = 10
    end
    respond_to do |format|
      format.json do
        render json: @site.scan_report
      end
    end
  end

  # POST /sites/1/scan/newseed
  def newseed
    puts "newseed CALLED!!!"
    @scan = Scan.new
    @scan.url = params[:url]
    puts params
    @scan.site = @site
    @scan.seed = true

    respond_to do |format|
      if @scan.save
        format.html { redirect_to [@site, @scan], notice: 'Seed was successfully created.' }
        format.json { render json: @scan }
      else
        format.html { render :new }
        format.json { render json: @scan.errors, status: :unprocessable_entity }
      end
    end
  end
  
  # GET /scans/1
  # GET /scans/1.json
  def show
  end

  # GET /scans/new
  def new
    @scan = Scan.new
    @scan.last_visited = nil
    @scan.site = @site
  end

  # GET /scans/1/edit
  def edit
  end

  # POST /scans
  # POST /scans.json
  def create
    @scan = Scan.new(scan_params)
    @scan.site = @site

    respond_to do |format|
      if @scan.save
        format.html { redirect_to [@site, @scan], notice: 'Scan was successfully created.' }
        format.json { render :show, status: :created, location: @scan }
      else
        format.html { render :new }
        format.json { render json: @scan.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /scans/1
  # PATCH/PUT /scans/1.json
  def update
    respond_to do |format|
      if @scan.update(scan_params)
        format.html { redirect_to [@site, @scan], notice: 'Scan was successfully updated.' }
        format.json { render :show, status: :ok, location: @scan }
      else
        format.html { render :edit }
        format.json { render json: @scan.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /scans/1
  # DELETE /scans/1.json
  def destroy
    @scan.destroy
    respond_to do |format|
      format.html { redirect_to site_scans_url(@site), notice: 'Scan was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_scan
      @scan = @site.scans.find(params[:id])
    end
    
    def set_site
      @site = Site.find(params[:site_id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def scan_params
      params.require(:scan).permit(:url, :content, :last_visited, :site_id)
    end
end
