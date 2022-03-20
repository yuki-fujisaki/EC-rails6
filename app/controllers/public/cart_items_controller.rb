class Public::CartItemsController < ApplicationController
  before_action :authenticate_customer!
  before_action :set_cart_item, only: [:create, :update, :destroy]

  def index
    # includesはN+1問題を解消するコード
    # 事前に読み込みをしておくモデル(カラム)を指定する
    # allでも良いがそれだと無駄にSQL文がが発行されてしまう
    @cart_items = current_customer.cart_items.includes(:item)
  end

  def create
    # ここでset_cart_itemとhas_in_cartを合わせて以下のようにしてもいいかも
    # has_in_cart = current_customer.cart_items.find_by(item_id: params[:item_id])
    # @cart_item = current_customer.has_in_cart
    # 以下に続く
    if @cart_item
      new_amount = @cart_item.amount + cart_item_params[:amount]
      @cart_item.update(amount: new_amount)
      redirect_to cart_items_path
    else
      @cart_item = current_customer.cart_items.new(cart_item_params)
      @cart_item.item_id = @item.id
      if @cart_item.save
        redirect_to cart_items_path
      else
        render 'public/items/show'
      end
    end
    # [004]旧Nagano_Cakeのcreateアクションは以下
    # @cart_item = CartItem.new(cart_item_params)
    # @cart_item.customer_id = current_customer.id
    #   if current_customer.cart_items.find_by(item_id: params[:cart_item][:item_id]).present?
    #    cart_item = current_customer.cart_items.find_by(item_id: params[:cart_item][:item_id])
    #    cart_item.amount += params[:cart_item][:amount].to_i
    #    cart_item.save
    #    redirect_to cart_items_path, notice: "You have created book successfully."
    #   elsif @cart_item.save
    #     redirect_to cart_items_path, notice: "You have created book successfully."
    #   else
    #     redirect_to item_path(@cart_item)
    #   end
  end

  def update
    @cart_item.update(cart_item_params) if @cart_item
    redirect_to cart_items_path
    
    # [004]旧Nagano_Cakeのupdateアクションは以下
    # @cart_item = CartItem.find_by(item_id: params[:cart_item][:item_id])
    # if @cart_item.update(amount: params[:cart_item][:amount])
    #   redirect_to cart_items_path, notice: "You have updated book successfully."
    # else
    #   render "edit"
    # end
  end

  def destroy
    @cart_item.destroy if @cart_item
    redirect_to cart_items_path

    # # [004]旧Nagano_Cakeのdestoryアクションは以下
    # @cart_item = CartItem.find(params[:id])
    # @cart_item.destroy
    # redirect_to cart_items_path
  end

  def destroy_all
    current_customer.cart_items.destroy_all
    redirect_to cart_items_path

    # [004]旧Nagano_Cakeのdestroy_allアクションは以下
    # @cart_item = current_end_user.cart_items
    # @cart_item.destroy_all
    # redirect_to cart_items_path
  end

  private

  def cart_item_params
    # item_idも送るなら許可すべき
    params.require(:cart_item).permit(:amount)
  end

  def set_cart_item
    @item = Item.find(params[:item_id])
    # [004]has_in_cartはCustomerモデルに記述してある以下
    # def has_in_cart(item)
    #   cart_items.find_by(item_id: item.id)
    # end
    @cart_item = current_customer.has_in_cart(@item)
  end
end

# 以下一応全文
# class Public::CartItemsController < ApplicationController
#   def index
#     @cart_items = CartItem.all
#   end

#   def create
#     @cart_item = CartItem.new(cart_item_params)
#     @cart_item.end_user_id = current_end_user.id
#     if current_end_user.cart_items.find_by(item_id: params[:cart_item][:item_id]).present?
#        cart_item = current_end_user.cart_items.find_by(item_id: params[:cart_item][:item_id])
#        cart_item.amount += params[:cart_item][:amount].to_i
#        cart_item.save
#        redirect_to cart_items_path, notice: "You have created book successfully."
#     elsif @cart_item.save
#       redirect_to cart_items_path, notice: "You have created book successfully."
#     else
#       redirect_to item_path(@cart_item)
#     end
#   end

#   def update
#     @cart_item = CartItem.find_by(item_id: params[:cart_item][:item_id])
#     if @cart_item.update(amount: params[:cart_item][:amount])
#       redirect_to cart_items_path, notice: "You have updated book successfully."
#     else
#       render "edit"
#     end
#   end

#   def destroy
#     @cart_item = CartItem.find(params[:id])
#     @cart_item.destroy
#     redirect_to cart_items_path
#   end

#   def destroy_all
#     @cart_item = current_end_user.cart_items
#     @cart_item.destroy_all
#     redirect_to cart_items_path
#   end

#   private

#   def cart_item_params
#     params.require(:cart_item).permit(:amount, :item_id)
#   end
# end