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

    describe  'line_item' do
      let(:line_items) { [ line_item ] }

      context "of normal kind" do
        let(:line_item) {{
          "name" => "Stained Tshirt",
        }}
        let(:result) { subject.line_items.first }
        before do
          subject.add_shopify_obj shopify_order, shopify_api
        end

        it 'is processed' do
          expect(result.name).to eq "Stained Tshirt"
        end

        it 'is alone' do
          expect(subject.line_items).to have(1).item
        end
      end

    end

  end
end
