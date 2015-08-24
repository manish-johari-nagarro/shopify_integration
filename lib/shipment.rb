class Shipment

  attr_reader :id, :shopify_id, :shopify_order_id, :status

  def add_shopify_obj shopify_shipment, shopify_api, shopify_order=nil, shipping_line=nil
    @store_name = Util.shopify_host(shopify_api.config).split('.')[0]
    @shopify_id = shopify_shipment['id']
    @shopify_order_id = shopify_shipment['order_id']
    @source = 'browser'
    @order = shopify_order || shopify_api.order(@shopify_order_id).first
    @email = @order.email
    @status = Util.wombat_shipment_status shopify_shipment['status']

    shipping_line ||= {}
    @cost = shipping_line['price']
    @shipping_method = shipping_line['title']
    
    @tracking = shopify_shipment['tracking_number']
    @shipped_at = shopify_shipment['created_at']

    @line_items = Array.new
    shopify_shipment['line_items'].each do |shopify_li|
      line_item = LineItem.new
      line_item.add_shopify_obj(shopify_li, shopify_api)
      @line_items << line_item.add_shopify_obj(shopify_li, shopify_api)
    end

    @shipping_address = @order.shipping_address
    @billing_address = @order.billing_address

    self
  end

  def add_shopify_obj_from_pos_line_items shopify_line_items, shopify_api, shopify_order=nil, shipping_line=nil
    @store_name = Util.shopify_host(shopify_api.config).split('.')[0]
    @shopify_id = nil
    @source = 'pos'
    @order = shopify_order || shopify_api.order(@shopify_order_id).first
    @shopify_order_id = shopify_order.shopify_id
    @email = @order.email
    @status = 'shipped'

    shipping_line ||= {}
    @cost =  0
    @shipping_method = 'pos'
    @shipped_at = @order.placed_on

    @line_items = Array.new
    shopify_line_items.each do |shopify_li|
      line_item = LineItem.new
      line_item.add_shopify_obj(shopify_li, shopify_api)
      @line_items << line_item.add_shopify_obj(shopify_li, shopify_api)
    end

    @shipping_address = @order.shipping_address
    @billing_address = @order.billing_address

    self
  end

  def add_wombat_obj wombat_shipment, shopify_api
    @shopify_order_id = wombat_shipment['id']
    @status = Util.shopify_shipment_status wombat_shipment['status']
    @shipping_method = wombat_shipment['shipping_method']
    @tracking_number = wombat_shipment['tracking']

    self
  end

  def shopify_obj
    {
      'status' => @status,
      'tracking_company' => @shipping_method,
      'tracking_number' => @tracking_number,
    }
  end

  def wombat_obj
    @stock_location = @source == 'pos' ? Util.config['pos_stock_location'] : Util.config['ecomm_stock_location']
    {
      'id' => @store_name.upcase + '-' + @shopify_order_id.to_s,
      'shopify_order_id' => @shopify_order_id.to_s,
      'shopify_id' => @shopify_id.to_s,
      'order_id' => @store_name.upcase + '-' + @shopify_order_id.to_s,
      'source' => @source,
      'stock_location' => @stock_location,
      'email' => @email,
      'status' => @status,
      'shipping_method' => @shipping_method,
      'tracking' => @tracking,
      'shipped_at' => @shipped_at,
      'shipping_address' => @shipping_address,
      'billing_address' => @billing_address,
      'items' => Util.wombat_array(@line_items),
      'cost' => @cost,
      'totals' => @order.totals
    }
  end
end
