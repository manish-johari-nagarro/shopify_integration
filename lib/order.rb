require 'ostruct'
class Order

  attr_reader :shopify_id, :email, :shipping_address, :billing_address, :store_name, :source, :line_items, :shipments, :totals, :shipping_lines, :placed_on

  def add_shopify_obj shopify_order, shopify_api
    @shopify_order = shopify_order

    @store_name = Util.shopify_host(shopify_api.config).split('.')[0]
    @order_number = shopify_order['order_number']
    @shopify_id = shopify_order['id']
    @source = 'pos'
    @status = 'complete'
    @note = shopify_order['note']
    @email = shopify_order['email']
    @shopify_customer_id = (shopify_order['customer'].presence || {})['id']
    @currency = shopify_order['currency']
    @placed_on = shopify_order['created_at']
    @totals_item = shopify_order['total_line_items_price'].to_f
    @totals_tax = shopify_order['total_tax'].to_f
    @totals_discounts = shopify_order['total_discounts'].to_f

    @payments = Array.new
    @totals_payment = 0.00
    sleep 1
    shopify_api.transactions(@shopify_id).each do |transaction|
      if (transaction.kind == 'capture' or transaction.kind == 'sale') and
          transaction.status == 'success'
        @totals_payment += transaction.amount.to_f
        payment = Payment.new
        @payments << payment.add_shopify_obj(transaction, shopify_api)
      end
    end

    @shipping_lines = shopify_order['shipping_lines'].to_a
    @totals_shipping = 0.00
    @shipping_lines.each do |shipping_line|
      @totals_shipping += shipping_line['price'].to_f
      payment = Payment.new
      # add shipping charge as payment otherwise spree will complain
      @payments << payment.add_shopify_obj(OpenStruct.new(amount: shipping_line['price'], gateway: shopify_order['gateway']), shopify_api)
    end

    @totals_order = shopify_order['total_price'].to_f
    @item_total = @totals_order - @payments.inject(0) {|sum, payment| sum += payment.amount.to_f}
    @payments << (Payment.new).add_shopify_obj(OpenStruct.new(amount: @item_total, gateway: 'shopify_payments'), shopify_api)

    @line_items = Array.new
    shopify_order['line_items'].each do |shopify_li|
      line_item = LineItem.new( order_percentage: calculate_order_discount_percentage )
      @line_items << line_item.add_shopify_obj(shopify_li, shopify_api)
    end

    unless shopify_order['shipping_address'].nil?
      @shipping_address = {
        'firstname' => shopify_order['shipping_address']['first_name'],
        'lastname' => shopify_order['shipping_address']['last_name'],
        'address1' => shopify_order['shipping_address']['address1'],
        'address2' => shopify_order['shipping_address']['address2'],
        'zipcode' => shopify_order['shipping_address']['zip'],
        'city' => shopify_order['shipping_address']['city'],
        'state' => shopify_order['shipping_address']['province'],
        'country' => shopify_order['shipping_address']['country_code'],
        'phone' => shopify_order['shipping_address']['phone']
      }
    end

    unless shopify_order['billing_address'].nil?
      @billing_address = {
        'firstname' => shopify_order['billing_address']['first_name'],
        'lastname' => shopify_order['billing_address']['last_name'],
        'address1' => shopify_order['billing_address']['address1'],
        'address2' => shopify_order['billing_address']['address2'],
        'zipcode' => shopify_order['billing_address']['zip'],
        'city' => shopify_order['billing_address']['city'],
        'state' => shopify_order['billing_address']['province'],
        'country' => shopify_order['billing_address']['country_code'],
        'phone' => shopify_order['billing_address']['phone']
      }
    end

    @shipments = Array.new
    if shopify_order['source'] == 'browser'
      shopify_order['fulfillments'].each_with_index do |shopify_shipment, idx|
        shipment = Shipment.new( order_percentage: calculate_order_discount_percentage )
        @shipments << shipment.add_shopify_obj(shopify_shipment, shopify_api, self, @shipping_lines[idx])
      end
    else
      shipment = Shipment.new( order_percentage: calculate_order_discount_percentage )
      @shipments << shipment.add_shopify_obj_from_pos_line_items(shopify_order['line_items'], shopify_api, self)
    end

    self
  end


  def calculate_order_discount_percentage
    unless @shopify_order['discount_codes'].empty?
      BigDecimal.new(@shopify_order['discount_codes'][0]['amount']) / BigDecimal.new(@shopify_order['total_line_items_price'])
    else
      0.0
    end
  end

  def wombat_obj
    {
      'id' => @store_name.upcase + '-' + @shopify_id.to_s,
      'shopify_order_number' => @order_number.to_s,
      'shopify_id' => @shopify_id.to_s,
      'source' => @source,
      'status' => @status,
      'note' => @note,
      'email' => @email,
      'shopify_customer_id' => @shopify_customer_id,
      'currency' => @currency,
      'placed_on' => @placed_on,
      'totals' => {
        'item' => @totals_item,
        'tax' => @totals_tax,
        'shipping' => @totals_shipping,
        'payment' => @totals_payment,
        'order' => @totals_order,
        'totals_discounts' => @totals_discounts,
      },
      'line_items' => Util.wombat_array(@line_items),
      'adjustments' => [
        {
          'name' => 'Tax',
          'value' => @totals_tax
        },
        # {
        #   'name' => 'Shipping',
        #   'value' => @totals_shipping
        # },
        {
          'name' => 'Discounts',
          'value' => @totals_discounts
        },
      ],
      'shipping_address' => @shipping_address,
      'billing_address' => @billing_address,
      'payments' => Util.wombat_array(@payments),
      'shipments' => Util.wombat_array(@shipments)
    }
  end

end
