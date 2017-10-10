module OrderHelpers
  def simple_order
    {id: 4092313419,
     email: "",
     closed_at: nil,
     created_at: "2017-04-05T10:21:13-04:00",
     updated_at: "2017-04-05T10:21:13-04:00",
     number: 47,
     note: "",
     token: "275dc998efa732a634d59e0e5a4cd224",
     gateway: "manual",
     test: false,
     total_price: "837.81",
     subtotal_price: "785.00",
     total_weight: 0,
     total_tax: "52.81",
     taxes_included: false,
     currency: "USD",
     financial_status: "paid",
     confirmed: true,
     total_discounts: "0.00",
     total_line_items_price: "785.00",
     cart_token: nil,
     buyer_accepts_marketing: false,
     name: "#1047",
     referring_site: nil,
     landing_site: nil,
     cancelled_at: nil,
     cancel_reason: nil,
     total_price_usd: "837.81",
     checkout_token: nil,
     reference: nil,
     user_id: 96594635,
     location_id: 13458443,
     source_identifier: nil,
     source_url: nil,
     processed_at: "2017-04-05T10:21:13-04:00",
     device_id: nil,
     browser_ip: nil,
     landing_site_ref: nil,
     order_number: 1047,
     discount_codes: [],
     note_attributes: [],
     payment_gateway_names: ["manual"],
     processing_method: "manual",
     checkout_id: nil,
     source_name: "shopify_draft_order",
     fulfillment_status: nil,
     tax_lines:
      [{title: "NY State Tax", price: "23.80", rate: 0.04},
       {title: "New York County Tax", price: "29.01", rate: 0.04875}],
     tags: "",
     contact_email: nil,
     order_status_url: nil,
     line_items:
      [{id: 7999252555,
        variant_id: 28603509259,
        title: "Be Optimistic Felt Badge - White with Black Border",
        quantity: 5,
        price: "1.00",
        grams: 0,
        sku: "11.BDG.BOPT.2.0",
        variant_title: nil,
        vendor: "Bestmade POS Staging",
        fulfillment_service: "manual",
        product_id: 8369606283,
        requires_shipping: true,
        taxable: true,
        gift_card: false,
        name: "Be Optimistic Felt Badge - White with Black Border",
        variant_inventory_management: nil,
        properties: [],
        product_exists: true,
        fulfillable_quantity: 5,
        total_discount: "0.00",
        fulfillment_status: nil,
        tax_lines:
         [{title: "NY State Tax", price: "0.20", rate: 0.04},
          {title: "New York County Tax", price: "0.25", rate: 0.04875}]},
       {id: 7999252619,
        variant_id: 28603749195,
        title: "Copy of The Standard Tee with Pocket - Large - Khaki",
        quantity: 5,
        price: "38.00",
        grams: 0,
        sku: "12.TEE.STPK.5.4",
        variant_title: nil,
        vendor: "Bestmade POS Staging",
        fulfillment_service: "manual",
        product_id: 8369638731,
        requires_shipping: true,
        taxable: true,
        gift_card: false,
        name: "Copy of The Standard Tee with Pocket - Large - Khaki",
        variant_inventory_management: nil,
        properties: [],
        product_exists: true,
        fulfillable_quantity: 5,
        total_discount: "0.00",
        fulfillment_status: nil,
        tax_lines: []},
       {id: 7999252683,
        variant_id: 28334291915,
        title: "The Featherweight Chambray Shirt - Large",
        quantity: 5,
        price: "118.00",
        grams: 0,
        sku: "12.SHT.WKFW.3.4",
        variant_title: nil,
        vendor: "Bestmade POS Staging",
        fulfillment_service: "manual",
        product_id: 8330748043,
        requires_shipping: true,
        taxable: true,
        gift_card: false,
        name: "The Featherweight Chambray Shirt - Large",
        variant_inventory_management: nil,
        properties: [],
        product_exists: true,
        fulfillable_quantity: 5,
        total_discount: "0.00",
        fulfillment_status: nil,
        tax_lines:
         [{title: "NY State Tax", price: "23.60", rate: 0.04},
          {title: "New York County Tax", price: "28.76", rate: 0.04875}]}],
     shipping_lines: [],
     fulfillments: [],
     refunds: []}.with_indifferent_access
  end
end
