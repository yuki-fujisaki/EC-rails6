class CartItem < ApplicationRecord
  belongs_to :customer
  belongs_to :item

  validates :item_id, uniqueness: { scope: :customer_id }
  validates :amount, presence: true, numericality: { greater_than_or_equal_to: 1, less_than_or_equal_to: 10 }

  # [004]カート機能該当箇所 Itemモデルでのwith_tax_priceと組み合わせて使う
  def subtotal
    # cart_itemのindexではcurrent_customerの値が入っているため、
    # subtotalにて紐づいたitemとamountが使える
    item.with_tax_price * amount
  end
end
