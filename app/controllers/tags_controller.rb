class TagsController < ApplicationController
  before_action :set_tag, only: [:show, :edit, :update, :destroy]

  # GET /tags
  # GET /tags.json
  def index
    # set default values
    around = (params[:around].blank? ? nil : params[:around])
    count = (params[:count].blank? ? 100 : params[:count].to_i)
    index = (params[:index].blank? ? 0 : params[:index].to_i)
    offset = (params[:offset].blank? ? 0 : params[:offset].to_i)
    start = [index + offset - count / 2, 0].max
    puts "count = #{count}"
    puts "index = #{index}"
    puts "offset = #{offset}"

    unless around.blank?
      Tag.order_by(name: :asc).each_with_index do |tag, i|
        if tag.name == around
          index = i
          break
        end
      end
      puts "found document #{around} at index #{index}"
    end
    
    start = [index + offset - count / 2, 0].max
    tags_list = Tag.order_by(name: :asc)
      .limit(count)
      .offset(start).as_json
    total_count = Tag.count
    
    respond_to do |format|
      if tags_list.blank?
        format.json { render json: { list: nil, low: nil, high: nil  } }
      else
        tags_list.each_with_index {|tag, i| tag[:index] = i + start}
        format.json { render json: 
                        {
                          list: tags_list,
                          total_count: total_count,
                        }
                    }
      end
    end
  end

  # GET /tags/1
  # GET /tags/1.json
  def show
  end

  # GET /tags/new
  def new
    @tag = Tag.new
  end

  # GET /tags/1/edit
  def edit
  end

  # POST /tags
  # POST /tags.json
  def create
    @tag = Tag.new(tag_params)

    respond_to do |format|
      if @tag.save
        format.json { render json: @scans, status: :created }
      else
        format.json { render json: @tag.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /tags/1
  # PATCH/PUT /tags/1.json
  def update
    respond_to do |format|
#       params[:tag].delete :_id
#       params[:tag].delete :keywords
#       params[:tag].delete :index
#       params[:tag].delete :name
#       puts params[:tag]
      puts tag_params
      sleep(3)
      if @tag.update(tag_params)
        format.json { render json: @tag }
      else
        format.json { render json: @tag.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /tags/1
  # DELETE /tags/1.json
  def destroy
    @tag.destroy
    respond_to do |format|
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_tag
      @tag = Tag.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def tag_params
      params.require(:tag).permit(:name, :do_ignore_word, :do_use_as_keyword, :do_use_as_product_description, :do_use_as_tag, {keywords: [:word]})
    end
end
