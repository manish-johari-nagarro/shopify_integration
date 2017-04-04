class LineItem

  attr_reader :sku


  attr_reader :name,
              :quantity,
              :price,
              :promo_total,
              :is_gift_card

  def add_shopify_obj shopify_li, shopify_api
    @shopify_id = shopify_li['id']
    @shopify_parent_id = shopify_li['product_id']
    @sku = shopify_li['sku']
    @name = shopify_li['name']
    @quantity = shopify_li['quantity'].to_i
    @price = shopify_li['price'].to_f
    @promo_total = shopify_li['total_discount'].to_f * -1
    @is_gift_card = shopify_li['name'].downcase.include? "gift card"
    self
  end

  def wombat_obj
    [
      {
        'product_id' => @sku,
        'shopify_id' => @shopify_id.to_s,
        'shopify_parent_id' => @shopify_parent_id.to_s,
        'name' => @name,
        'quantity' => @quantity,
        'price' => @price,
        'is_gift_card' => @is_gift_card,
        'promo_total' => @promo_total,
        'adjustment_total' => @promo_total
      }
    ]
  end

end
