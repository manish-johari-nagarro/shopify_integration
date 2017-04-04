require 'spec_helper'

describe Order do

  describe '#add_shopify_obj' do
    let(:shopify_order) {{
      "line_items" => line_items,
    }}
    let(:shopify_api) {
      double 'ShopifyAPI',
        transactions: [],
        config: {
          "shopify_host" => "foo.bar.com",
        }
    }

    describe  'line_items' do
      let(:line_items) { [] }

      it 'are forwared' do
        subject.add_shopify_obj shopify_order, shopify_api

        expect(subject.line_items).to be_empty
        subject.line_items.first
      end
    end

  end
end
