require "test_helper"

module GobiertoAdmin
  module GobiertoCommon
    class ContentBlockPolicyTest < ActiveSupport::TestCase
      def regular_admin
        @regular_admin ||= gobierto_admin_admins(:tony)
      end

      def manager_admin
        @manager_admin ||= gobierto_admin_admins(:nick)
      end

      def content_block
        @content_block ||= gobierto_common_content_blocks(:contact_methods)
      end

      def test_view?
        assert ContentBlockPolicy.new(manager_admin, content_block).view?
        assert ContentBlockPolicy.new(regular_admin, content_block).view?
      end

      def test_create?
        assert ContentBlockPolicy.new(manager_admin, content_block).create?
        refute ContentBlockPolicy.new(regular_admin, content_block).create?
      end

      def test_update?
        assert ContentBlockPolicy.new(manager_admin, content_block).update?
        refute ContentBlockPolicy.new(regular_admin, content_block).update?
      end

      def test_delete?
        assert ContentBlockPolicy.new(manager_admin, content_block).delete?
        refute ContentBlockPolicy.new(regular_admin, content_block).delete?
      end
    end
  end
end
