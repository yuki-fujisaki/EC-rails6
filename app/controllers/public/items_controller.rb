class Public::ItemsController < ApplicationController
  # [003]商品登録機能該当箇所
  # [008]ジャンル検索機能該当箇所
  def index
    @genres = Genre.only_active
    if params[:genre_id]
      @genre = @genres.find(params[:genre_id])
      all_items = @genre.items
    else
      all_items = Item.where_genre_active.includes(:genre)
    end
    # [003]ページネーションは必須ではない
    # @items = Item.all でもOK
    @items = all_items.page(params[:page]).per(12)
    @all_items_count = all_items.count
  end

  def show
    @item = Item.where_genre_active.find(params[:id])
    @genres = Genre.only_active
    @cart_item = CartItem.new
  end
end
