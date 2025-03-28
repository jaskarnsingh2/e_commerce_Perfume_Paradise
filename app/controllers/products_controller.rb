class ProductsController < ApplicationController
  before_action :check_admin_priv, except: ["index", "show"]
  before_action :set_product, only: %i[ show edit update destroy ]

  # GET /products or /products.json
  def index
    @categories = Category.all
    @products = Product.all
    

    # Add logging to check images
  @products.each do |product|
    Rails.logger.debug "Product #{product.id}: Images count = #{product.images.count}"
  end
  
    # Apply filter based on params
    if params[:filter] == 'on_sale'
      @products = @products.where(on_sale: true)
    elsif params[:filter] == 'new_products'
      @products = @products.where('created_at >= ?', 3.days.ago)
    elsif params[:filter] == 'recently_updated'
      @products = @products.where('updated_at >= ?', 3.days.ago)
    end

     # Apply search filter using pg_search_scope
  if params[:search].present?
    @products = Product.search_by_name_and_description(params[:search])
  end

  if params[:category_id].present?
    @products = @products.where(category_id: params[:category_id])
  end

    # Paginate Results 
    @products = @products.page(params[:page]).per(10)
  end  

  # GET /products/1 or /products/1.json
  def show
  end

  # GET /products/new
  def new
    @product = Product.new
  end

  # GET /products/1/edit
  def edit
  end

  # POST /products or /products.json
  def create
    @product = Product.new(product_params)

    respond_to do |format|
      if @product.save
        format.html { redirect_to @product, notice: "Product was successfully created." }
        format.json { render :show, status: :created, location: @product }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @product.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /products/1 or /products/1.json
  def update
    respond_to do |format|
      if @product.update(product_params)
        format.html { redirect_to @product, notice: "Product was successfully updated." }
        format.json { render :show, status: :ok, location: @product }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @product.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /products/1 or /products/1.json
  def destroy
    @product.destroy!

    respond_to do |format|
      format.html { redirect_to products_path, status: :see_other, notice: "Product was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_product
      @product = Product.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def product_params
      params.require(:product).permit(:name, :description, :price, :category_id, :on_sale, images: [])
    end
end
