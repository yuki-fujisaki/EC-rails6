class Admin::HomesController < ApplicationController
  before_action :authenticate_admin!
  def top
    @count = Order.ordered_today.count
  end
  
  def search
    @model = params['search']['model']
    @content = params['search']['content']
    @method = params['search']['method']
    @result = search_for(@model, @content, @method)
  end

  private

  def search_for(model, content, method)
    if model == 'customer'
      if method == 'forward'
        Customer.where(
          'last_name LIKE ? OR first_name LIKE? OR last_name_kana LIKE? OR first_name_kana LIKE?',
          "#{content}%", "#{content}%", "#{content}%", "#{content}%"
        )
      elsif method == 'backward'
        Customer.where(
          'last_name LIKE ? OR first_name LIKE? OR last_name_kana LIKE? OR first_name_kana LIKE?',
          "%#{content}", "%#{content}", "%#{content}", "%#{content}"
        )
      elsif method == 'perfect'
        Customer.where(
          'last_name = ? OR first_name = ? OR last_name_kana = ? OR first_name_kana = ?',
          content, content, content, content
        )
      else # partial
        Customer.where(
          'last_name LIKE ? OR first_name LIKE? OR last_name_kana LIKE? OR first_name_kana LIKE?',
          "%#{content}%", "%#{content}%", "%#{content}%", "%#{content}%"
        )
      end
    elsif model == 'item'
      if method == 'forward'
        Item.where('name LIKE ?', content + '%').includes(:genre)
      elsif method == 'backward'
        Item.where('name LIKE ?', '%' + content).includes(:genre)
      elsif method == 'perfect'
        Item.where(name: content).includes(:genre)
      else # partial
        Item.where('name LIKE ?', '%' + content + '%').includes(:genre)
      end
    else
      [] # 空配列を返す
    end
  end
end

# [007]旧nagano_cakeでの検索機能実装方法↓

# ①Admin/Itemsコントローラーのindexアクションに以下を記述
# def index
#   # @items = Item.all
#   # Item.rbに上記を記述
#   @items = Item.search(params[:search])
# end
# 
# ②Itemモデルにserchメソッドを追記
# 
# def self.search(search)
# if search
#   Item.where(['name LIKE ?', "%#{search}%"])
# else
#   Item.all
# end
# end
# 
# ③Viewにform_withを記述
# <%= form_with url: admin_items_path :method => 'get' do %>
#   <%= text_field_tag :search %>
#   <%= submit_tag 'Search', :name => nil %>
# <% end %>