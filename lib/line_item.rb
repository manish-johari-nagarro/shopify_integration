class LineItem

  attr_reader :sku


  attr_reader :name,
              :quantity,
              :price,
              :promo_total,
              :is_gift_card

  def initialize(order_percentage: 0)
    @order_percentage = order_percentage
  end

  def add_shopify_obj shopify_li, shopify_api
    @shopify_li = shopify_li
    @shopify_api = shopify_api

    @shopify_id = shopify_li['id']
    @shopify_parent_id = shopify_li['product_id']
    @sku = shopify_li['sku']
    @name = shopify_li['name']
    @quantity = shopify_li['quantity']
    @price = shopify_li['price']
    @is_gift_card = shopify_li['name'].downcase.include? "gift card"
    self
  end

  # Discount in a single item
  def caculate_item_promotion
    (single_item_promotion + whole_order_item_promotion).to_f
  end

  # Discount * quantity
  def total_items_promotion
    @shopify_li['quantity'].to_f * caculate_item_promotion
  end

  def wombat_obj
    [
      {
        'product_id' => @sku,
        'sku' => @sku,
        'shopify_id' => @shopify_id.to_s,
        'shopify_parent_id' => @shopify_parent_id.to_s,
        'name' => @name,
        'quantity' => @quantity,
        'price' => @price.to_f,
        'is_gift_card' => @is_gift_card,
        'promo_item' => caculate_item_promotion,
        'promo_total' => total_items_promotion,
      }
    ]
  end

  private

  def single_item_promotion
    BigDecimal.new(@shopify_li['total_discount'].to_s) / @shopify_li['quantity']
  end

  def whole_order_item_promotion
    (BigDecimal.new(@price) * @order_percentage)
  end
end
