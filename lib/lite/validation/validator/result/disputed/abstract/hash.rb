# frozen_string_literal: true

require_relative 'instance'
require_relative '../../disputable/hash'

module Lite
  module Validation
    module Validator
      module Result
        module Disputed
          module Abstract
            class Hash < Abstract::Instance
              include Disputable::Hash

              Lite::Data.define(self, args: %i[errors_root])

              def append(result, key)
                raise Error::Fatal, "Key already taken #{key}" if children.key? key

                super
              end

              def signature(class_name)
                super(class_name, " with #{errors_root.count} root errors, #{children.count} children")
              end
            end
          end
        end
      end
    end
  end
end
